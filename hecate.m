function hecate(cfgPath)
% HECATE - Runs continuous procrustes dist, diffusion, and clustering analysis 

path(pathdef);
addpath(path,genpath(pwd));

load(cfgPath, 'cfg');

%% Continuous Procrustes distance
if cfg.ctrl.runFlatten
	cluster_run('cluster_flatten', ['''' cfg.path.cfg ''''], pwd, ...
		cfg.path.flat, 'flatten', 1, '', cfg.msc.email, cfg.msc.emailAddress);
end

if cfg.ctrl.runListFlatMeshes
	cluster_run('get_flat_meshes', ['''' cfg.path.cfg ''''], pwd, ...
		cfg.path.flat, 'getflat', 1, 'fjob*', cfg.msc.email, ...
		cfg.msc.emailAddress);
	load(cfgPath, 'cfg');
end

if cfg.ctrl.runCPD
	cluster_run('cluster_cpd', ['''' cfg.path.cfg ''''], pwd, cfg.path.cpd, ...
		'cpd', 1, 'getflat', cfg.msc.email, cfg.msc.emailAddress);
	pcrArg = ['''' cfg.path.cpdJobMats ''', ''' cfg.path.cpd ''', ' ...
		num2str(length(cfg.data.flatSamples)) ', ' num2str(cfg.param.chunkSize)];
	cluster_run('process_cpd_results', pcrArg, pwd, cfg.path.cpd, ...
		'pcr', 1, 'cpdjob*', cfg.msc.email, cfg.msc.emailAddress);
	cluster_run('mesh_to_structs', ['''' cfg.path.cfg ''''], pwd, cfg.path.cpd, ...
		'm2s', 1, 'pcr', cfg.msc.email, cfg.msc.emailAddress);
end

if cfg.ctrl.runCPDMST
	cluster_run('cluster_cpd_mst', ['''' cfg.path.cfg ''''], pwd, cfg.path.cpdMST, ...
		'cpm', 1, 'm2s', cfg.msc.email, cfg.msc.emailAddress);
end

% Needs to be replaced by python step
% if cfg.ctrl.runCPDImprove
% 	cluster_run('cluster_improve_cpd', ['''' cfg.path.cfg ''''], pwd, ...
% 		cfg.path.cpdImprove, 'cpdi', 1, 'pcr', cfg.msc.email, ...
% 		cfg.msc.emailAddress);
% 	pcriArg = ['''' cfg.path.cpdImproveJobMats ''', ''' cfg.path.cpdImprove ...
% 		''', ' num2str(length(cfg.data.flatSamples)) ', ' ... 
% 		num2str(cfg.param.chunkSize) ', ''_MST'''];
% 	cluster_run('process_cpd_results', pcriArg, pwd, cfg.path.cpdImprove, ...
% 		'pcri', 1, 'ijob*', cfg.msc.email, cfg.msc.emailAddress);
% end

%% Diffusion map and consistent spectral clustering
if cfg.ctrl.runSoften
	cluster_run('cluster_soften', ['''' cfg.path.cfg ''''], pwd, ...
		cfg.path.soften, 'soften', 1, 'cpm', cfg.msc.email, ...
		cfg.msc.emailAddress);
end

if cfg.ctrl.runDiffMapSpectCluster
	cluster_run('cluster_csc', ['''' cfg.path.cfg ''''], pwd, ...
		cfg.path.csc, 'csc', 1, 'Sjob*', cfg.msc.email, cfg.msc.emailAddress);
end

end


