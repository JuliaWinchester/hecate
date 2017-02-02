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

% invoke cluster_soften.m
softenPath = cluster_soften(flatSamples, outputDir, procImprResultsPath, 1e-3, 25);

% set-up for segment.m
%% preparation
close all;
path(pathdef);
addpath(path,genpath([pwd '/utils/']));

%% setup parameters
BaseEps = 0.03;
BNN = 5;
FibrEps = 1e-3;
MapType = 'cPMST';
FeatureFix = 'Off';
GroupLevel = 'Genus';
% GroupNames = {'Purgatorius','Pronothodectes','Tupaia','Lemur',...
%     'Microcebus','Cantius','Arctocebus','Adapis','Lepilemur',...
%     'Eosimias','Cynocephalus','Leptacodon','Nycticebus'};
% GroupNames = {'Euprimates','Primates','Dermoptera','Scandentia','Incertae sedis'};
% GroupNames = {'Purgatorius'};
GroupNames = {'Purgatorius','Pronothodectes'};
% GroupNames = {'Purgatorius','Pronothodectes','Tupaia','Lemur'};
% GroupNames = {'Purgatorius','Pronothodectes','Tupaia','Lemur',...
%     'Microcebus','Cantius','Arctocebus','Adapis','Lepilemur',...
%     'Eosimias','Cynocephalus'};
% GroupNames = {'Donrussellia','Cheirogaleus','Avahi','Eulemur',...
%     'Hapalemur','Loris','Nycticebus','Leptacodon'};
% GroupNames = {'Tupaia','Galago'};
% GroupNames = {'Purgatorius','Tupaia','Pronothodectes','Varecia','Microcebus','Lemur'};

%% setup paths
base_path = [pwd '/'];
data_path = '../data/';
spreadsheet_path = [data_path 'ClassificationTable.xlsx'];
sample_path = '../cPdist/samples/PNAS/';
result_path = '../cPdist/impr_results/';
soften_path = './soften/';
% TextureCoords1Path = [result_path 'TextureCoords1/'];
% TextureCoords2Path = [result_path 'TextureCoords2/'];

%% load taxa codes
taxa_file = [data_path 'teeth_taxa_table.mat'];
taxa_code = load(taxa_file);
taxa_code = taxa_code.taxa_code;
GroupSize = length(taxa_code);
ChunkSize = 25; %% PNAS % JMW changing this from 55 to 25 temporarily to match previous files

%% options that control the diffusion eigenvector visualization
options.sample_path = sample_path;
options.DisplayLayout = [2,4];
options.DisplayOrient = 'Horizontal';
options.boundary = 'on';
options.names = 'off';

% invoke segment.m

