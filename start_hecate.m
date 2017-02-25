%% Script to start hecate.m as a cluster job

clear all;
close all;
path(pathdef);
addpath(path,genpath(pwd));

cfg = get_cfg();
if cfg.ctrl.restartAll
	set_up_dirs(cfg, 1);
	save(cfg.path.cfg, 'cfg');
else
	set_up_dirs(cfg, 0);
	if exist(cfg.path.cfg, 'file') == 2
        load(cfg.path.cfg, 'cfg');
    else
    	save(cfg.path.cfg, 'cfg');
    end
end

cluster_run('hecate', ['''' cfg.path.cfg ''''], pwd, ...
	fullfile(cfg.path.outputDir, '/etc/'), 'hecate', 0, '', cfg.msc.email, ...
	cfg.msc.emailAddress);