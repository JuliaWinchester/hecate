function cluster_csc(cfgPath)
% CLUSTER_CSC - Carry out consistent spectral clustering analysis on cluster
	load(cfgPath); 
	vIdxCumSum = vertex_idx_cumsum(cfg.data.flatSamples);
	[H, diffMatrixSize] = build_diffusion(cfg, vIdxCumSum);
	[U, ~, sqrtInvD] = eigen_decomp(H, diffMatrixSize, cfg.param.eigCols);
	kIdx = spectral_cluster(cfg, U, sqrtInvD);

	%% Constructing and exporting results
	result = SegResult(cfg.data.flatSamples, kIdx, vIdxCumSum, cfg);
	result.calc_data();
	result.export(cfg.param.alignTeeth);

end
