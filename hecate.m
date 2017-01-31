% Set up working environment: add paths, create all necessary subdirectories
clear all;
close all;
path(pathdef);
addpath(path,genpath(pwd));


config;

% At some point add delete commands for starting over in directories
% Set-up for cluster_flatten.m
touch(outputDir);
touch(fullfile(outputDir, '/etc/flatten/samples'));
touch(fullfile(outputDir, '/etc/flatten/cluster/script'));
touch(fullfile(outputDir, '/etc/flatten/cluster/error'));
touch(fullfile(outputDir, '/etc/flatten/cluster/out'));

[meshNames, meshPaths] = get_mesh_names(meshDir, '.off');

% invoke cluster_flatten.m
flatSamples = cluster_flatten(meshNames, meshPaths, outputDir, pwd);

% Set-up from cluster_cPdist

% invoke cluster_cPdist.m
%[cpdResultPath, cpdChunk] = cluster_cPdist(meshNames, meshDir, outputDir, 25);

% set-up for cPProcess_Rslts_landmarkfree_old.m

% invoke process_results_cpd.m
%process_cluster_cpd(cpdResultPath, outputDir, length(meshNames), cpdChunk);

% Set-up for cluster_Imprdist_landmarkfree
