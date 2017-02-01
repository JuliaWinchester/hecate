% Set up working environment: add paths, create all necessary subdirectories
clear all;
close all;
path(pathdef);
addpath(path,genpath(pwd));


config;

system(['rm -rf ' outputDir]);

% At some point add delete commands for starting over in directories
% Set-up for cluster_flatten.m
touch(outputDir);
touch(fullfile(outputDir, '/etc/flatten/samples'));
touch(fullfile(outputDir, '/etc/flatten/cluster/script'));
touch(fullfile(outputDir, '/etc/flatten/cluster/error'));
touch(fullfile(outputDir, '/etc/flatten/cluster/out'));
delete(fullfile(outputDir, '/etc/flatten/samples/*'));
delete(fullfile(outputDir, '/etc/flatten/cluster/script/*'));
delete(fullfile(outputDir, '/etc/flatten/cluster/error/*'));
delete(fullfile(outputDir, '/etc/flatten/cluster/out/*'));

[meshNames, meshPaths] = get_mesh_names(meshDir, '.off');

% invoke cluster_flatten.m
flatSamples = cluster_flatten(meshNames, meshPaths, outputDir, pwd);

% Set-up from cluster_cPdist
touch(fullfile(outputDir, '/etc/cpd/job_mats'));
touch(fullfile(outputDir, '/etc/cpd/cluster/script'));
touch(fullfile(outputDir, '/etc/cpd/cluster/error'));
touch(fullfile(outputDir, '/etc/cpd/cluster/out'));
delete(fullfile(outputDir, '/etc/cpd/job_mats/*'));
delete(fullfile(outputDir, '/etc/cpd/cluster/script/*'));
delete(fullfile(outputDir, '/etc/cpd/cluster/error/*'));
delete(fullfile(outputDir, '/etc/cpd/cluster/out/*'));


% invoke cluster_cPdist.m
[cpdResultPath, cpdChunk] = cluster_cPdist(flatSamples, outputDir, 2);

% set-up for cPProcess_Rslts_landmarkfree_old.m
touch(fullfile(outputDir, 'etc/cpd/texture_coords_1'));
touch(fullfile(outputDir, 'etc/cpd/texture_coords_2'));

% invoke process_results_cpd.m
process_results_cpd(cpdResultPath, outputDir, length(meshNames), cpdChunk);

% Set-up for cluster_Imprdist_landmarkfree
