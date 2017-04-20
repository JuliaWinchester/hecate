function set_up_dirs(cfg, fileDel)
% SET_UP_DIRS - Create directories outlined in cfg, opt. delete files in dirs

touch(cfg.path.outputDir);
touch(fullfile(cfg.path.outputDir, '/etc'));

touch(fullfile(cfg.path.flat, '/samples'));
touch(fullfile(cfg.path.flat, '/cluster/script'));
touch(fullfile(cfg.path.flat, '/cluster/error'));
touch(fullfile(cfg.path.flat, '/cluster/out'));

touch(cfg.path.cpdJobMats);
touch(fullfile(cfg.path.cpd, '/cluster/script'));
touch(fullfile(cfg.path.cpd, '/cluster/error'));
touch(fullfile(cfg.path.cpd, '/cluster/out'));
touch(fullfile(cfg.path.cpd, '/texture_coords_1'));
touch(fullfile(cfg.path.cpd, '/texture_coords_2'));

touch(cfg.path.cpdMST);
touch(fullfile(cfg.path.cpdMST, '/cluster/out_error'));
touch(fullfile(cfg.path.cpdMST, '/mesh'));

touch(fullfile(cfg.path.soften, '/job_mats'));
touch(fullfile(cfg.path.soften, '/cluster/script'));
touch(fullfile(cfg.path.soften, '/cluster/error'));
touch(fullfile(cfg.path.soften, '/cluster/out'));

touch(cfg.path.out);

if fileDel
	delete_recursively(cfg.path.outputDir);
end
