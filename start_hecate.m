%% Script to start hecate.m as a cluster job

clear all;
close all;
path(pathdef);
addpath(path,genpath(pwd));

cfg = get_cfg();
set_up_dirs(cfg, 0);
save(cfg.path.cfg, 'cfg');

cluster_run('hecate', ['''' cfg.path.cfg ''''], pwd, ...
	fullfile(cfg.path.outputDir, '/etc/'), 'hecate', 0, '', cfg.msc.email, ...
	cfg.msc.emailAddress);