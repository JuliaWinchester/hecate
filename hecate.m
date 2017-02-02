% Set up working environment: add paths, create all necessary subdirectories
clear all;
close all;
path(pathdef);
addpath(path,genpath(pwd));


config;

%%%%%%%%% cPDistMST

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
[cpdResultPath, cpdChunk] = cluster_cPdist(flatSamples, outputDir, 25);

% set-up for cPProcess_Rslts_landmarkfree_old.m
touch(fullfile(outputDir, 'etc/cpd/texture_coords_1'));
touch(fullfile(outputDir, 'etc/cpd/texture_coords_2'));
delete(fullfile(outputDir, 'etc/cpd/texture_coords_1/*'));
delete(fullfile(outputDir, 'etc/cpd/texture_coords_2/*'));

% invoke process_results_cpd.m
procResultsPath = process_cpd_results(cpdResultPath, fullfile(outputDir, '/etc/cpd/'), length(meshNames), cpdChunk);

% Set-up for cluster_improve_cpd
touch(fullfile(outputDir, '/etc/cpd_improve/job_mats'));
touch(fullfile(outputDir, '/etc/cpd_improve/cluster/script'));
touch(fullfile(outputDir, '/etc/cpd_improve/cluster/error'));
touch(fullfile(outputDir, '/etc/cpd_improve/cluster/out'));
delete(fullfile(outputDir, '/etc/cpd_improve/job_mats/*'));
delete(fullfile(outputDir, '/etc/cpd_improve/cluster/script/*'));
delete(fullfile(outputDir, '/etc/cpd_improve/cluster/error/*'));
delete(fullfile(outputDir, '/etc/cpd_improve/cluster/out/*'));

% invoke cluster_improve_cpd.m
[cpdImprResultPath, cpdImprChunk] = cluster_improve_cpd('MST', 'off', flatSamples, outputDir, procResultPath, 2);

% set-up for second process_cpd_results.m
touch(fullfile(outputDir, 'etc/cpd_improve/texture_coords_1'));
touch(fullfile(outputDir, 'etc/cpd_improve/texture_coords_2'));
delete(fullfile(outputDir, 'etc/cpd_improve/*'));
delete(fullfile(outputDir, 'etc/cpd_improve/texture_coords_1/*'));
delete(fullfile(outputDir, 'etc/cpd_improve/texture_coords_2/*'));

procImprResultsPath = process_cpd_results(cpdImprResultPath, fullfile(outputDir, '/etc/cpd_improve/'), length(meshNames), cpdImprChunk, '_MST');

%%%%%%%%% HDM

% set-up for cluster_mapsoften.m
%%% preparation
clearvars;
close all;
path(pathdef);
addpath(path,genpath([pwd '/utils/']));

%%% setup paths
base_path = [pwd '/'];
data_path = '../data/';
rslt_path = '../cPdist/impr_results/';

cluster_path = [base_path 'cluster/'];
samples_path = '../cPdist/samples/PNAS/';

TaxaCode_path = [data_path 'teeth_taxa_table.mat'];
TextureCoords1_path = [rslt_path '/TextureCoords1/'];
TextureCoords2_path = [rslt_path '/TextureCoords2/'];

scripts_path = [cluster_path 'scripts/'];
errors_path = [cluster_path 'errors/'];
outputs_path = [cluster_path 'outputs/'];

soften_path = './soften/';

%%% build folders if they don't exist
touch(scripts_path);
touch(errors_path);
touch(outputs_path);
touch(soften_path);

%%% clean up paths
command_text = ['!rm -f ' scripts_path '*']; eval(command_text); disp(command_text);
command_text = ['!rm -f ' errors_path '*']; eval(command_text); disp(command_text);
command_text = ['!rm -f ' outputs_path '*']; eval(command_text); disp(command_text);
command_text = ['!rm -f ' soften_path '*']; eval(command_text); disp(command_text);

%%% load taxa codes
taxa_code = load(TaxaCode_path);
taxa_code = taxa_code.taxa_code;
GroupSize = length(taxa_code);
chunk_size = 25; %% HDM
FibrEps = 1e-3;

% invoke cluster_soften.m
softenPath = cluster_soften(fiberEps, chunkSize);
