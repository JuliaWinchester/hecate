path(pathdef);
addpath(path,genpath(pwd));

load('~/p/etc/cfg.mat');

vIdxCumSum = vertex_idx_cumsum(cfg.data.flatSamples);

[H, diffMatrixSize] = do_diffusion(cfg, vIdxCumSum);

[U, ~, sqrtInvD] = eigen_decomp(H, diffMatrixSize);

kIdx = do_csc(cfg, U, sqrtInvD);

res = SegResult(cfg.data.flatSamples, kIdx, vIdxCumSum);

save('~/p/output/res.mat');