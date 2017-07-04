function flatten_ongrid(mesh_file, sample_file)
%sample_relax_cP:   sample on one surface
%   Detailed explanation goes here
%
% Minor modification by Julie Winchester (julie.winchester@duke.edu)

%==========================================================================
% Preprocessing
%==========================================================================

[~, ~, meshExt] = fileparts(mesh_file);
if strcmpi(meshExt, '.off')
	G = Mesh('off', mesh_file);
elseif strcmpi(meshExt, '.ply')
	G = Mesh('ply', mesh_file);
else
	error('Unrecognized or unsupported mesh file extension.');
end

%G.remove_zero_area_faces();
%G.remove_unref_verts();'
G.DeleteIsolatedVertex();
sep_i = strfind(mesh_file, filesep);
dot_i = strfind(mesh_file, '.');
G.Aux.name = mesh_file(sep_i(end)+1:dot_i(end)-1);
[G.Aux.Area,G.Aux.Center] = G.Centralize('ScaleArea');
disp(num2str(norm(G.V,'fro')));
%options.GaussMaxLocalWidth = 12; %% for Clement data set
%options.GaussMinLocalWidth = 7; %% for Clement data set
options = struct;
G.ComputeMidEdgeUniformization(options); %%% default options only for PNAS

G.Nf = G.ComputeFaceNormals;
G.Nv = G.F2V'*G.Nf';
G.Nv = G.Nv'*diag(1./sqrt(sum((G.Nv').^2,1)));

%%% Compute cotangent Laplacian operator.
G.Aux.LB = G.ComputeCotanLaplacian;

%%% Save results to a .mat file.
save(sample_file, 'G');

end

