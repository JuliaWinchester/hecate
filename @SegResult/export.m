function export(SegResult, alignTeeth)
% EXPORT - Saves SegResult object and all data with write/plot methods

	outPath = SegResult.cfg.path.out;

	if alignTeeth
		SegResult.align(1);
	end

	%%% Write mesh, segment, group OFFs
	SegResult.write_meshes(fullfile(outPath, 'mesh'));
	SegResult.write_segments(fullfile(outPath, 'segment'), ...
		1, SegResult.cfg.msc.dirCollate, SegResult.cfg.param.colorSegments);
	SegResult.write_seg_group(fullfile(outPath, 'seg_group.off'), ...
		SegResult.cfg.param.colorSegments);

	%%% Write CSV tables
	SegResult.write_mesh_table_csv(fullfile(outPath, 'mesh.csv'));
	SegResult.write_seg_table_csv(fullfile(outPath, 'segment.csv'));

	%%% Plot and save figures
	SegResult.plot_freq_dist(fullfile(outPath, 'freq_dist.eps'));
	SegResult.plot_segments_3d(SegResult.cfg.msc.nMeshDisplay, ...
		fullfile(outPath, 'segment.fig'));

	%%% Save result object
	save(fullfile(outPath, 'result.mat'), 'SegResult');

	disp('File export done!');

end