# -*- coding: utf-8 -*-
"""Improve continuous procrustes distance/maps using a minimum spanning tree.

This module contains code to use Spark to improve continuous Procrustes (CP) 
comparisons for a sample of 3D meshes using a minimum spanning tree (MST) 
constructed from previously computed pairwise CP distances. For each pair of 
meshes (ex: A, B), improvement is carried out by 1) determining the shortest CP 
distance path between these meshes on a MST (ex: A, L, Q, B); 2) computing CP 
maps in the form of texture coordinates along the path from A to B by 
interpolating/propogating these quantities along path segments 
(ex: A-L -> L-Q -> Q-B => A-B); and 3) computing new CP distance, point-to-point
maps, and rotation matrices from the propogated texture coordinate maps. This 
should result in lower CP distances and better alignments between mesh pairs 
compared to the initial pairwise CP comparisons.

Because this module is design to ingest data from MATLAB and to export data back
to MATLAB as part of the Hecate software package, certain .MAT-format input
files are required. See Hecate MATLAB code for more information on how these 
files should be calculated. These must be specified in the module code below. 
MATLAB .MAT-format output files will be produced when analysis is finished. 
These include TBD.

Attributes:
	mesh_path (str): Path to directory of .MAT file meshes
	mesh_name_path (str): Path to .MAT file cell array of mesh names
	cp_dist_path (str): Path to .MAT file array of pairwise CP distances
	tc1_mat_path (str): Path to .MAT file of pairwise 1st texture coordinates
	tc2_mat_path (str): Path to .MAT file of pairwise 2nd texture coordinates
	out_path (str): Path where output files should be saved.

Todo:
	* This single module should be broken up into sub-units
	* Functions need real documentation 
	* Unit testing

Author: Julie Winchester (julia.winchester@duke.edu)
"""

import itertools
import cPickle as pickle
import scipy as sp
import scipy.io as sp_io
import scipy.linalg as sp_linalg
import scipy.spatial as sp_spatial
import scipy.sparse.csgraph as sp_graph
import warnings

from functools import partial
from math import ceil, sqrt
from os import listdir, makedirs
from os.path import isfile, exists, join
from pyspark import SparkContext, SparkConf
from shutil import rmtree
from sys import argv

##################
# Spark analysis #
##################

class Improve_Result:
	"""Currently unused due to difficulties passing classes to Spark"""
	def __init__(self, mesh1_i, mesh2_i, tc1, tc2, pt_map, inv_pt_map, dist, r, ref):
		self.mesh1_i = mesh1_i
		self.mesh2_i = mesh2_i
		self.tc1 = tc1
		self.tc2 = tc2
		self.pt_map = pt_map
		self.inv_pt_map = inv_pt_map
		self.dist = dist
		self.r = r
		self.ref = ref

def all_pairs(l):
	return list(itertools.product(l, repeat=2))

def mst(dist_array):
	"""Derive MST from distance array, return MST, new dists, and predecessors"""
	t = sp_graph.minimum_spanning_tree(dist_array)
	new_dists, pred = sp_graph.dijkstra(t, directed=0, return_predecessors=1)
	return t, new_dists, pred

def mst_path(uv):
	u, v = uv
	if u == v:
		return [u]
	if predBC.value[u, v] == -9999:
		return None
	p = [u]
	while u != v:
		u = predBC.value[v, u]
		p.append(u)
	return p

def mst_paths_by_len(sc, pair):
	pair_rdd = sc.parallelize(pair)
	pair_paths = pair_rdd.map(mst_path)
	return sorted(pair_paths.groupBy(len).collect())

def cpd_mst_export(pair_paths_collate):
	for i in range(len(pair_paths_collate)):
		print("Processing paths of length %d" % i)
		x = sc.parallelize(pair_paths_collate[i][1])
		x.foreach(calc_save_cpd_mst)
		
def calc_save_cpd_mst(path):
	print("Calculating result object for path %s" % path)
	if len(path) == 1:
		m1_i = m2_i = path[0]
		m1 = m2 = read_mesh_mat(m.value[path[0]])
		tc1 = [load_input_tc(path[0], path[0], 1)]
		tc2 = [load_input_tc(path[0], path[0], 2)]
	elif len(path) == 2:
		m1_i = path[0]
		m2_i = path[1]
		m1 = read_mesh_mat(m.value[path[0]])
		m2 = read_mesh_mat(m.value[path[1]])
		tc1 = [load_input_tc(path[0], path[1], 1)]
		tc2 = [load_input_tc(path[0], path[1], 2)]
	else:
		m1_i = path[0]
		m2_i = path[-1]
		m1 = read_mesh_mat(m.value[path[0]])
		m2 = read_mesh_mat(m.value[path[-1]])
		tc1 = [load_output_tc(path[0], path[-2], 1), load_input_tc(path[-2], path[-1], 1)]
		tc2 = [load_output_tc(path[0], path[-2], 2), load_input_tc(path[-2], path[-1], 2)]
	result = improve_cp_with_path_edges(m1, m2, tc1, tc2)
	sp_io.savemat(join(out_path_bc.value, 'tc1/', str(m1_i+1), 
		str(m1_i+1)+'_'+str(m2_i+1)+'.mat'), {'tc1': result['tc1']})
	sp_io.savemat(join(out_path_bc.value, 'tc2/', str(m1_i+1), 
		str(m1_i+1)+'_'+str(m2_i+1)+'.mat'), {'tc2': result['tc2']})
	misc = {'pt_map': result['pt_map'], 'inv_pt_map': result['inv_pt_map'], 'dist': result['dist'], 'r': result['r'], 'ref': result['ref']}
	sp_io.savemat(join(out_path_bc.value, 'misc/', str(m1_i+1), 
		str(m1_i+1)+'_'+str(m2_i+1)+'.mat'), {'misc': misc})

def export_cpdist(pairs, out_path):
	print('Exporting cpdist..')
	n = sqrt(len(pairs))
	d = sc.parallelize(pairs).map(get_cpdist).collect()
	cpdist = sp.empty([n, n], dtype=float)
	ind = zip(*pairs)
	cpdist[ind[0], ind[1]] = d
	sp_io.savemat(join(out_path, 'cpdist_mst.mat'), {'cpdist': cpdist})
	print('Done exporting cpdist!')

# Currently unused functions (i.e., functions that store result array in memory)

def cpd_mst_array(d, pair_paths_collate):
	result_array = sp.empty(d.value.shape, dtype=object)
	result_BC = sc.broadcast(result_array)
	for i in range(len(pair_paths_collate)):
		print("Processing paths of length %d" % i)
		x = sc.parallelize(pair_paths_collate[i][1])
		x_objs = x.map(partial(calc_return_cpd_mst, result_BC=result_BC)).collect()
		if len(list(pair_paths_collate[i][1])[0]) == 1:
			ind = [y[0] for y in list(pair_paths_collate[i][1])]
			d_inds = [ind, ind]
		else:
			d_inds = zip(*list(pair_paths_collate[i][1]))
		result_array[d_inds[0], d_inds[-1]] = x_objs
		result_BC.destroy()
		result_BC = sc.broadcast(result_array)
	return result_array

def calc_return_cpd_mst(path, result_BC):
	print("Calculating result object for path %s" % path)
	if len(path) == 1:
		m1_i = m2_i = path[0]
		m1 = m2 = read_mesh_mat(m.value[path[0]])
		tc1 = [tc1_array.value[path[0], path[0]]]
		tc2 = [tc2_array.value[path[0], path[0]]]
	elif len(path) == 2:
		m1_i = path[0]
		m2_i = path[1]
		m1 = read_mesh_mat(m.value[path[0]])
		m2 = read_mesh_mat(m.value[path[1]])
		tc1 = [tc1_array.value[path[0], path[1]]]
		tc2 = [tc2_array.value[path[0], path[1]]]
	else:
		m1_i = path[0]
		m2_i = path[-1]
		m1 = read_mesh_mat(m.value[path[0]])
		m2 = read_mesh_mat(m.value[path[-1]])
		tc1 = [result_BC.value[path[0], path[-2]]['tc1'], # 1 x 2, 2 x 3 tc1s
			tc1_array.value[path[-2], path[-1]]]
		tc2 = [result_BC.value[path[0], path[-2]]['tc2'], 
			tc2_array.value[path[-2], path[-1]]]
	return improve_cp_with_path_edges(m1, m2, tc1, tc2)

##############
# Improve CP #
##############

def map_to_dist(v1, v2, v_map, v1_area):
	"""v1 & v2: npts x dim arrays, v_map: npts vector, v1_area: npts vector"""
	r, t, dist = rigid_motion(v1, v2[v_map, :], v1_area)
	return dist, r, t

def rigid_motion(p, q, p_area):
	"""P & Q: npts x dim arrays, P_area: npts vector"""
	if p.shape[0] != q.shape[0]:
		raise ValueError('p and q arrays not equal size')
	mp = sp.mean(p, 0)
	mq = sp.mean(q, 0)
	t = mq - mp
	p = p - sp.dot(sp.ones([p.shape[0], 1]), mp.reshape([1, 3]))
	q = q - sp.dot(sp.ones([q.shape[0], 1]), mq.reshape([1, 3]))
	u, _, v = sp_linalg.svd(sp.dot(p.transpose(), q))
	r = sp.dot(v.transpose(), u.transpose())
	tp = sp.dot(r, p.transpose()).transpose()
	err = sp.sqrt(sp.dot(p_area.transpose(), sp.sum((tp - q)**2, 1)))[0]
	return r, t, err

def tc_from_two_edges(e1_tc1, e1_tc2, e2_tc1, e2_tc2):
	return build_tc_along_nodes(e2_tc1, e1_tc1, e1_tc2), e2_tc2

def build_tc_along_nodes(tc1, next_node_tc1, next_node_tc2):
	bbox = sp.array([[-1, -1, 1, 1], [-1, 1, -1, 1]])
	next_node_tc2 = sp.concatenate((next_node_tc2, bbox), axis=1)
	tc1 = sp.concatenate((tc1, bbox), axis=1)
	tri = sp_spatial.Delaunay(next_node_tc2.transpose())
	new_tc1 = sp.zeros(next_node_tc1.shape)
	simp_i = tri.find_simplex(next_node_tc1.transpose())
	no_i = sp.where(simp_i == -1)[0]
	if len(no_i) > 0:
		warnings.warn("Points %s not found in any triangle, staying where they were." % (', '.join(map(str, no_i))), RuntimeWarning)
		new_tc1[:, no_i] = next_node_tc1[:, no_i]
	match_i = sp.where(simp_i != -1)[0]
	BC = barycoords(tri, simp_i[match_i], next_node_tc1[:, match_i].transpose())
	tc1_verts = tc1[:, tri.simplices[simp_i[match_i]]].transpose([1, 0, 2])
	new_verts = sp.array(map(lambda i: sp.dot(tc1_verts[i], BC[i].transpose()), range(tc1_verts.shape[0]))).transpose()
	new_tc1[:, match_i] = new_verts
	return new_tc1

def barycoords(tri, faces, points):
	# Because python and matlab can have different point order within triangles, column order is not guaranteed
	# Faces should be in format triangle indices, points in npts x dim array
	X = tri.transform[faces, :-1]
	Y = points - tri.transform[faces, -1]
	b = sp.einsum('ijk,ik->ij', X, Y)
	return sp.c_[b, 1 - b.sum(axis=1)]

def improve_cp_with_path_edges(mesh1, mesh2, tc1, tc2):
	"""Improves continuous procrustes distance/map given texture coordinates
	for path edges (path length must be 1-3 nodes).
	Input variables:
		mesh1 & mesh2: @Mesh Matlab objs as dict via scipy.io.loadmat()
		tc1 & tc2: Lists with texture coordinate arrays,
	Output variables:
		Dict with fields:
			'tc1' & 'tc2': Texture coordinates propogated along path
			'pt_map': Map of tc1 points on tc2 (use on tc2 to get tc1's shape)
			'inv_pt_map': Map of tc2 points on tc1 (vice versa from above)
			'dist': New continuous procrustes distance as propogated along path
			'r': Rotation matrix between meshes
			'ref': Boolean indicating if rotation matrix involves reflection
	"""
	if len(tc1) == 1:
		new_tc1 = tc1[0]
		new_tc2 = tc2[0]
	elif len(tc1) == 2:
		new_tc1, new_tc2 = tc_from_two_edges(tc1[0], tc2[0], tc1[1], tc2[1])
	else:
		raise ValueError('improve_cp_with_path_edges() only handles 1 or 2 edges, use improve_cp_with_path_nodes()')
	tc2_kd = sp_spatial.KDTree(new_tc2.transpose())
	pt_map = tc2_kd.query(new_tc1.transpose())[1]
	tc1_kd = sp_spatial.KDTree(new_tc1.transpose())
	inv_pt_map = tc1_kd.query(new_tc2.transpose())[1]
	dist, r, _ = map_to_dist(mesh1['v'], mesh2['v'], pt_map, mesh1['vert_area'])
	if sp_linalg.det(r) > 0:
		ref = 0
	else:
		ref = 1
	return {'tc1': new_tc1, 'tc2': new_tc2, 'pt_map': pt_map, 
		'inv_pt_map': inv_pt_map, 'dist': dist, 'r': r, 'ref': ref}

# Currently unused functions (i.e., improving CPD from path nodes)

def improve_cp_with_path_nodes(mesh1, mesh2, path, tc1_path, tc2_path):
	"""Improves continuous procrustes distance/map using path from MST.

	Input variables:
		mesh1 & mesh2: dict with fields
			'v': npts x dim vertex matrix
			'v_area': vertex area from hecate
			'i': index in tc1 and tc2 arrays
			'name': mesh name (optional)
		path: list of mesh indices for MST path from mesh1 to mesh2
		tc1_path & tc2_path: Paths to Matlab .mat file of tc1/tc2 cell arrays
	
	Output variables:
		Dict with fields:
			'tc1' & 'tc2': Texture coordinates propogated along path
			'pt_map': Map of tc1 points on tc2 (use on tc2 to get tc1's shape)
			'inv_pt_map': Map of tc2 points on tc1 (vice versa from above)
			'dist': New continuous procrustes distance as propogated along path
			'r': Rotation matrix between meshes
			'ref': Boolean indicating if rotation matrix involves reflection
	"""
	tc1_mat = sp_io.loadmat(tc1_path)['tc1_mat']
	tc2_mat = sp_io.loadmat(tc2_path)['tc2_mat']
	new_tc1, new_tc2 = compose_tc_along_path(path, tc1_mat, tc2_mat)
	tc2_kd = sp_spatial.KDTree(new_tc2.transpose())
	pt_map = tc2_kd.query(new_tc1.transpose())
	tc1_kd = sp_spatial.KDTree(new_tc1.transpose())
	inv_pt_map = tc1_kd.query(new_tc2.transpose())
	dist, r, _ = map_to_dist(mesh1_v, mesh2_v, pt_map, mesh1_v_area)
	if sp_linalg.det(r) > 0:
		ref = 0
	else:
		ref = 1
	return {'tc1': new_tc1, 'tc2': new_tc2, 'pt_map': pt_map, 
		'inv_pt_map': inv_pt_map, 'dist': dist, 'r': r, 'ref': ref}

def compose_tc_along_path(path, tc1_mat, tc2_mat):
	if len(path) == 1:
		return (tc1_mat[path[0], path[0]], tc2_mat[path[0], path[0]])

	new_tc1 = tc1_mat[path[-2], path[-1]] # 2 x 3, e2_tc1
	new_tc2 = tc2_mat[path[-2], path[-1]] # 2 x 3, e2_tc2

	if len(path) > 2:
		for i in range(-2, -len(path), -1):
			print('Working on nodes %d and %d' % (path[i-1], path[i]))
			next_node_tc1 = tc1_mat[path[i-1], path[i]] # 1 x 2, e1_tc1
			next_node_tc2 = tc2_mat[path[i-1], path[i]] # 1 x 2, e1_tc2
			new_tc1 = build_tc_along_nodes(new_tc1, next_node_tc1, next_node_tc2)

	return new_tc1, new_tc2

############
# File I/O #
############

def touch(dir_path):
	if not exists(dir_path):
		makedirs(dir_path)

def make_output_dirs(out_path, sub_dirs, n):
	"""out_path: Base directory; sub_dirs: Sub-directories, n: Mesh number"""
	for d in sub_dirs:
		touch(join(out_path, d))
		for i in range(n):
			touch(join(out_path, d, str(i + 1)))

def read_mesh_mat(path):
	"""Loads 3D mesh matlab object as dictionary"""
	f = sp_io.loadmat(path)['m']
	return {'v': f['V'][0][0].transpose(), 'vert_area': f['Aux'][0][0]['VertArea'][0][0].transpose()}

def load_output_tc(i, j, type):
	"""type: 1 or 2; i & j: Mesh indices"""
	if type == 1:
		src_dir = join(out_path_bc.value, 'tc1/')
		key = 'tc1'
	elif type == 2: 
		src_dir = join(out_path_bc.value, 'tc2/')
		key = 'tc2'
	else:
		raise ValueError('Invalid type')
	return sp_io.loadmat(join(src_dir, str(i+1), str(i+1)+'_'+str(j+1)+'.mat'))[key]

def load_input_tc(i, j, type):
	"""i & j: Mesh indices; type: 1 or 2; chunk_size: mats/block, path: Block location"""
	if type == 1:
		file_pre = "TextureCoords1_mat_"
		path = join(cpd_path_bc.value, "texture_coords_1/")
		mat_name = "tc1"
	elif type == 2:
		file_pre = "TextureCoords2_mat_"
		path = join(cpd_path_bc.value, "texture_coords_2/")
		mat_name = "tc2"
	else:
		raise ValueError('Invalid type')
	mat_i = int(ceil(float(i * n_bc.value + (j + 1))/float(chunk_size_bc.value)))
	mat = sp_io.loadmat(join(path, (file_pre + str(mat_i) + '.mat')))[mat_name]
	return mat[i, j]

def get_cpdist(uv):
	u, v = uv
	misc = sp_io.loadmat(join(out_path_bc.value, 'misc/', str(u+1), 
		str(u+1)+'_'+str(v+1)+'.mat'))['misc']
	return misc[0][0]['dist'][0][0]

if __name__ == "__main__":
	# Load data
	print("Loading MATLAB data")
	cfg_path = argv[1]
	cfg = sp_io.loadmat(cfg_path)['cfg']
	chunk_size = cfg[0][0]['param'][0][0]['chunkSize'][0][0]
	cpd_path = cfg[0][0]['path'][0][0]['cpd'][0]
	tc_path = cfg[0][0]['path'][0][0]['cpdJobMats'][0]
	out_path = cfg[0][0]['path'][0][0]['cpdMST'][0]
	mesh_list = [m[0][0] for m in cfg[0][0]['data'][0][0]['meshStructs']]

	cp_dist = sp_io.loadmat(join(cpd_path, 'cpDistMatrix.mat'))['cpDist']
	print("Finished loading MATLAB data")

	make_output_dirs(out_path, ['tc1/', 'tc2/', 'misc/'], len(mesh_list))

	# Construct Spark Context
	conf = SparkConf().setAppName('cpd_mst')
	sc = SparkContext(conf=conf)

	# Broadcast variables
	m = sc.broadcast(mesh_list)
	_, _, pred = mst(cp_dist)
	predBC = sc.broadcast(pred)
	cpd_path_bc = sc.broadcast(cpd_path)
	out_path_bc = sc.broadcast(out_path)
	chunk_size_bc = sc.broadcast(chunk_size)
	n_bc = sc.broadcast(len(mesh_list))

	# Analysis
	print("Starting CPD improvement")
	pairs = all_pairs(range(len(mesh_list)))
	pair_paths_collate = mst_paths_by_len(sc, pairs)
	cpd_mst_export(pair_paths_collate)
	export_cpdist(pairs, out_path)
	print("Finished CPD improvement")

	