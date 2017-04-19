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
from os import listdir
from os.path import isfile, join
from pyspark import SparkContext, SparkConf

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

def read_mesh_mat(path):
	"""Loads 3D mesh matlab object as dictionary"""
	f = sp_io.loadmat(path)['m']
	return {'v': f[0][0][0].transpose(), 'vert_area': f[0][0][1].transpose()}

def load_tc(source, type, i, j):
	"""source: 'in' or 'out'; type: 1 or 2; i & j: Mesh indices"""
	if source == 'in':
		src_dir = '/gtmp/BoyerLab/julie/spark_test/tmp/in_'
	elif source == 'out':
		src_dir = '/gtmp/BoyerLab/julie/spark_test/tmp/out_'
	else:
		raise ValueError('Invalid source')

	if type == 1:
		src_dir = src_dir + 'tc1'
	elif type == 2: 
		src_dir = src_dir + 'tc2'
	else:
		raise ValueError('Invalid type')

	return pickle.load(open(join(src_dir, str(i)+'_'+str(j)), 'rb'))

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

def mst_paths_by_len(sc, mesh_list):
	pair = all_pairs(range(len(mesh_list)))
	pair_rdd = sc.parallelize(pair)
	pair_paths = pair_rdd.map(mst_path)
	return sorted(pair_paths.groupBy(len).collect())

def cpd_mst_export(d, pair_paths_collate):
	for i in range(len(pair_paths_collate)):
		print("Processing paths of length %d" % i)
		x = sc.parallelize(pair_paths_collate[i][1])
		x.foreach(calc_save_cpd_mst)
		
def calc_save_cpd_mst(path):
	print("Calculating result object for path %s" % path)
	if len(path) == 1:
		m1_i = m2_i = path[0]
		m1 = m2 = read_mesh_mat(m.value[path[0]])
		tc1 = [load_tc('in', 1, path[0], path[0])]
		tc2 = [load_tc('in', 2, path[0], path[0])]
	elif len(path) == 2:
		m1_i = path[0]
		m2_i = path[1]
		m1 = read_mesh_mat(m.value[path[0]])
		m2 = read_mesh_mat(m.value[path[1]])
		tc1 = [load_tc('in', 1, path[0], path[1])]
		tc2 = [load_tc('in', 2, path[0], path[1])]
	else:
		m1_i = path[0]
		m2_i = path[-1]
		m1 = read_mesh_mat(m.value[path[0]])
		m2 = read_mesh_mat(m.value[path[-1]])
		tc1 = [load_tc('out', 1, path[0], path[-2]), load_tc('in', 1, path[-2], path[-1])]
		tc2 = [load_tc('out', 2, path[0], path[-2]), load_tc('in', 2, path[-2], path[-1])]
		
	result = improve_cp_with_path_edges(m1, m2, tc1, tc2)
	pickle.dump(result['tc1'], open(join('/gtmp/BoyerLab/julie/spark_test/tmp/out_tc1/', str(m1_i)+'_'+str(m2_i)), 'wb'))
	pickle.dump(result['tc2'], open(join('/gtmp/BoyerLab/julie/spark_test/tmp/out_tc2/', str(m1_i)+'_'+str(m2_i)), 'wb'))
	etc = {'pt_map': result['pt_map'], 'inv_pt_map': result['inv_pt_map'], 'dist': result['dist'], 'r': result['r'], 'ref': result['ref']}
	pickle.dump(etc, open(join('/gtmp/BoyerLab/julie/spark_test/tmp/out_etc/', str(m1_i)+'_'+str(m2_i)), 'wb'))

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
	dist, r, _ = map_to_dist(mesh1['v'], mesh2['v'], pt_map, mesh1['vert_area'])\
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

if __name__ == "__main__":
	# Module-level variables
	mesh_path = '/gtmp/BoyerLab/julie/spark_test/mesh/'
	mesh_names_path = '/gtmp/BoyerLab/julie/spark_test/meshnames.mat'
	cp_dist_path = '/gtmp/BoyerLab/julie/spark_test/cpDistMatrix.mat'
	tc1_mat_path = '/gtmp/BoyerLab/julie/spark_test/tc1.mat'
	tc2_mat_path = '/gtmp/BoyerLab/julie/spark_test/tc2.mat'
	out_path = '/gtmp/BoyerLab/julie/spark_test/'

	# Construct Spark Context
	conf = SparkConf().setAppName('cpd_mst')
	sc = SparkContext(conf=conf)

	# Load data
	print("Loading MATLAB data")
	mesh_names = sp_io.loadmat(mesh_names_path)['f']
	mesh_list = [join(mesh_path, (x[0][0]+'.mat')) for x in mesh_names \
		if isfile(join(mesh_path, (x[0][0]+'.mat')))]
	cp_dist = sp_io.loadmat(cp_dist_path)['cpDist']
	print("Finished loading MATLAB data")

	# Broadcast variables
	d = sc.broadcast(cp_dist)
	m = sc.broadcast(mesh_list)
	_, _, pred = mst(cp_dist)
	predBC = sc.broadcast(pred)
	out_path_bc = sc.broadcast(out_path)

	# Analysis
	print("Starting CPD improvement")
	pair_paths_collate = mst_paths_by_len(sc, mesh_list)
	result = cpd_mst_array(d, pair_paths_collate)
	print("Finished CPD improvement")
	pickle.dump(result, open(join(out_path, 'cpd_res_final'), 'wb'))