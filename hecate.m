% Set up working environment: add paths, create all necessary subdirectories
clear all;
close all;
path(pathdef);
addpath(path,genpath(pwd));

cfg = get_cfg(cfgSave = 1);
set_up_dirs(cfg, fileDel = 1);

%%%%%%%%% cPDistMST
flatSamples = cluster_flatten(cfg.path.cfg);

cfg.data.flatSamples = flatSamples;
save(cfg.path.cfg, 'cfg');

cluster_cpd(cfg.path.cfg);

process_cpd_results(cfg.path.cpdJobMats, cfg.path.cpd, length(flatSamples), ...
	cfg.params.chunkSize);

cluster_improve_cpd(cfg.path.cfg);

process_cpd_results(cfg.path.cpdImproveJobmats, cfg.path.cpdImprove, ...
	length(flatSamples), cfg.params.chunkSize, '_MST');

%%%%%%%%% HDM
softenPath = cluster_soften(cfg.path.cfg);

vIdxCumSum = vertex_idx_cumsum(cfg.data.flatSamples);

[H, diffMatrixSize] = do_diffusion(cfg, vIdxCumSum);

[U, ~, sqrtInvD] = eigen_decomp(H, diffMatrixSize);

kIdx = do_csc(cfg, U, sqrtInvD);

res = SegResult(cfg.data.flatSamples, kIdx, vIdxCumSum);



