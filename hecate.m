%% Script to run software analysis steps

% Set up working environment: add paths, create all necessary subdirectories
clear all;
close all;
path(pathdef);
addpath(path,genpath(pwd));

cfg = get_cfg();
set_up_dirs(cfg, 0);
save(cfg.path.cfg, 'cfg');

%% Continuous Procrustes distance
%cluster_run('cluster_flatten', {cfg.path.cfg}, pwd, cfg.path.flat, ...
%	'flatten', 1, '', cfg.msc.email, cfg.msc.emailAddress)
flatSamples = cluster_flatten(cfg.path.cfg);

cfg.data.flatSamples = flatSamples;
save(cfg.path.cfg, 'cfg');

%cluster_cpd(cfg.path.cfg);
cluster_run('cluster_cpd', ['''' cfg.path.cfg ''''], pwd, cfg.path.cpd, ...
	'cpd', 1, 'fjob*', cfg.msc.email, cfg.msc.emailAddress);

pcrArg = ['''' cfg.path.cpdJobMats ''', ''' cfg.path.cpd ''', ' ...
	num2str(length(flatSamples)) ', ' num2str(cfg.param.chunkSize)];
cluster_run('process_cpd_results', pcrArg, pwd, cfg.path.cpd, ...
	'pcr', 1, 'cpdjob*', cfg.msc.email, cfg.msc.emailAddress);

%process_cpd_results(cfg.path.cpdJobMats, cfg.path.cpd, length(flatSamples), ...
%	cfg.param.chunkSize);

cluster_run('cluster_improve_cpd', ['''' cfg.path.cfg ''''], pwd, cfg.path.cpdImprove, ...
	'cpdi', 1, 'pcr', cfg.msc.email, cfg.msc.emailAddress);
%cluster_improve_cpd(cfg.path.cfg);

pcriArg = ['''' cfg.path.cpdImproveJobMats ''', ''' cfg.path.cpdImprove ''', ' ...
	num2str(length(flatSamples)) ', ' num2str(cfg.param.chunkSize) ', ''_MST'''];
cluster_run('process_cpd_results', pcriArg, pwd, cfg.path.cpdImprove, ...
	'pcri', 1, 'ijob*', cfg.msc.email, cfg.msc.emailAddress);

%process_cpd_results(cfg.path.cpdImproveJobmats, cfg.path.cpdImprove, ...
%	length(flatSamples), cfg.param.chunkSize, '_MST');

%% Diffusion map and consistent spectral clustering
% softenPath = cluster_soften(cfg.path.cfg);
cluster_run('cluster_soften', ['''' cfg.path.cfg ''''], pwd, cfg.path.soften, ...
	'soften', 1, 'pcri', cfg.msc.email, cfg.msc.emailAddress);

vIdxCumSum = vertex_idx_cumsum(cfg.data.flatSamples);

[H, diffMatrixSize] = build_diffusion(cfg, vIdxCumSum);

[U, ~, sqrtInvD] = eigen_decomp(H, diffMatrixSize);

kIdx = spectral_cluster(cfg, U, sqrtInvD);

%% Constructing and exporting results
result = SegResult(cfg.data.flatSamples, kIdx, vIdxCumSum, cfg);
result.calc_data();
result.export(cfg.param.alignTeeth);



