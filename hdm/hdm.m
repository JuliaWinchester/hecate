function hdm(cfg)
% HDM - Carries out HDM analysis

% Set up directories
touch(fullfile(outputDir, '/etc/soften/mats/'));
touch(fullfile(outputDir, '/etc/soften/cluster/script'));
touch(fullfile(outputDir, '/etc/soften/cluster/error'));
touch(fullfile(outputDir, '/etc/soften/cluster/out'));
touch(fullfile(outputDir, '/output'));
touch(fullfile(outputDir, '/output/segments'));

% Clean up old files
delete(fullfile(outputDir, '/etc/soften/mats/*'));
delete(fullfile(outputDir, '/etc/soften/cluster/script/*'));
delete(fullfile(outputDir, '/etc/soften/cluster/error/*'));
delete(fullfile(outputDir, '/etc/soften/cluster/out/*'));
delete(fullfile(outputDir, '/output/*'));
delete(fullfile(outputDir, '/output/segments/*'));

softenPath = cluster_soften(cfg);

[vIdxCumSum, vIdxArray] = vertex_idx_cumsum(cfg.samplePath);

%% collection rigid motions /// Need to change this to generate rigid motions
R = rigid_motion(cfg.samplePath, cfg.imprMapPath);

[H, diffMatrixSize] = diffusion(cfg, vIdxCumSum, softenPath);

[U, ~, sqrtInvD] = eigen_decomp(H, diffMatrixSize);

%==========================================================================
%%% consistent spectral clustering on each surface
%==========================================================================

kIdx = csc(cfg);

%ViewBundleFunc(Names,idx,options);

segByMesh = seg_by_mesh(cfg);

% JMW additions to extract segments as needed
