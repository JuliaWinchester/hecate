function mesh_to_structs(cfgPath)
% MESH_TO_STRUCTS - Converts @Mesh object to structs, adds list to cfg object

load(cfgPath);
[n, p] = get_mesh_names(cfg.path.flatSample, '.mat');
warning('off','all'); % Suppress struct() warning
for i = 1:length(p)
	load(p{i});
	m = struct(G);
	save(fullfile(cfg.path.cpdMST, '/mesh', [n{i} '_struct.mat']), 'm');
end
warning('on','all');
[structN, structP] = get_mesh_names(fullfile(cfg.path.cpdMST, '/mesh'), '.mat');
cfg.data.meshStructs = structP;
save(cfgPath, 'cfg');