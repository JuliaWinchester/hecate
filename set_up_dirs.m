function set_up_dirs(cfg, fileDel)
% SET_UP_DIRS - Create directories outlined in cfg, opt. delete files in dirs

touch(outputDir);

touch(fullfile(cfg.path.flatPath, '/samples'));
touch(fullfile(cfg.path.flatPath, '/cluster/script'));
touch(fullfile(cfg.path.flatPath, '/cluster/error'));
touch(fullfile(cfg.path.flatPath, '/cluster/out'));

touch(cfg.path.cpdJobMats);
touch(fullfile(cfg.path.cpdResults, '/cluster/script'));
touch(fullfile(cfg.path.cpdResults, '/cluster/error'));
touch(fullfile(cfg.path.cpdResults, '/cluster/out'));
touch(fullfile(cfg.path.cpdResults, '/texture_coords_1'));
touch(fullfile(cfg.path.cpdResults, '/texture_coords_2'));

touch(cfg.path.cpdImproveJobMats);
touch(fullfile(cfg.path.cpdImproveResults, '/cluster/script'));
touch(fullfile(cfg.path.cpdImproveResults, '/cluster/error'));
touch(fullfile(cfg.path.cpdImproveResults, '/cluster/out'));
touch(fullfile(cfg.path.cpdImproveResults, '/texture_coords_1'));
touch(fullfile(cfg.path.cpdImproveResults, '/texture_coords_2'));

touch(fullfile(softenPath, '/mats/'));
touch(fullfile(softenPath, '/cluster/script'));
touch(fullfile(softenPath, '/cluster/error'));
touch(fullfile(softenPath, '/cluster/out'));

touch(cfg.path.outPath);
touch(cfg.path.segmentsPath);

if fileDel
	delete_recursively(outputDir);
end