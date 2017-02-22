function get_flat_meshes(cfgPath)
% GET_FLAT_MESHES - Gets list of flat meshes and adds them to cfg object

load(cfgPath);
[n, p] = get_mesh_names(cfg.path.flatSample, '.mat');
cfg.data.flatSamples = p;
save(cfgPath, 'cfg');
