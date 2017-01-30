% Set up working environment: add paths, create all necessary subdirectories

config;

% Set-up from cluster_flatten.m
%%% preparation
clear all;
close all;
path(pathdef);
addpath(path,genpath([pwd '/utils/']));

%%% setup paths
base_path = [pwd '/'];
data_path = '../data';
meshes_path = [data_path 'meshes/'];
samples_path = [base_path 'samples/PNAS/'];
cluster_path = [base_path 'cluster/'];
scripts_path = [cluster_path 'scripts/'];
errors_path = [cluster_path 'errors/'];
outputs_path = [cluster_path 'outputs/'];

%%% build folders if they don't exist
touch(samples_path);
touch(scripts_path);
touch(errors_path);
touch(outputs_path);

%%% clean up paths
command_text = ['!rm -f ' scripts_path '*']; eval(command_text); disp(command_text);
command_text = ['!rm -f ' errors_path '*']; eval(command_text); disp(command_text);
command_text = ['!rm -f ' outputs_path '*']; eval(command_text); disp(command_text);
command_text = ['!rm -f ' samples_path '*']; eval(command_text); disp(command_text);

%%% load taxa codes
taxa_file = [data_path 'teeth_taxa_table.mat'];
taxa_code = load(taxa_file);
taxa_code = taxa_code.taxa_code;
GroupSize = length(taxa_code);

% invoke cluster_flatten.m
[meshes, meshNames] = cluster_flatten(meshDir, outputDir, codePath);

% Set-up from cluster_cPdist
%%% preparation
clear vars;
close all;
path(pathdef);
addpath(path,genpath([pwd '/utils/']));

%%% setup paths
base_path = [pwd '/'];
data_path = '../data/';
rslts_path = [base_path 'rslts/'];
cluster_path = [base_path 'cluster/'];
samples_path = [base_path 'samples/PNAS/'];
meshes_path = [data_path 'meshes/'];
scripts_path = [cluster_path 'scripts/'];
errors_path = [cluster_path 'errors/'];
outputs_path = [cluster_path 'outputs/'];

%%% build folders if they don't exist
touch(scripts_path);
touch(errors_path);
touch(outputs_path);
touch(rslts_path);

%%% clean up paths
command_text = ['!rm -f ' scripts_path '*']; eval(command_text); disp(command_text);
command_text = ['!rm -f ' errors_path '*']; eval(command_text); disp(command_text);
command_text = ['!rm -f ' outputs_path '*']; eval(command_text); disp(command_text);
command_text = ['!rm -f ' rslts_path '*']; eval(command_text); disp(command_text);

%%% load taxa codes
taxa_file = [data_path 'teeth_taxa_table.mat'];
taxa_code = load(taxa_file);
taxa_code = taxa_code.taxa_code;
GroupSize = length(taxa_code);
chunk_size = 25; %% Clement

% invoke cluster_cPdist.m
[cpdResultPath, cpdChunk] = cluster_cPdist(meshNames, meshDir, outputDir, 25);

% set-up for cPProcess_Rslts_landmarkfree_old.m
%%% preparation
clearvars;
close all;
path(pathdef);
addpath(path,genpath([pwd '/utils/']));

%%% setup paths
base_path = [pwd '/'];
data_path = '../data/';
result_path = [base_path 'results/']; 
rslts_path = [base_path 'rslts/'];
TextureCoords1Matrix_path = [result_path 'TextureCoords1/'];
TextureCoords2Matrix_path = [result_path 'TextureCoords2/'];

%%% check if texture paths exist
touch(result_path);
touch(TextureCoords1Matrix_path);
touch(TextureCoords2Matrix_path);

%%% clean up texture coordinates matrices
command_text = ['!rm -f ' TextureCoords1Matrix_path '*'];
eval(command_text); disp(command_text);
command_text = ['!rm -f ' TextureCoords2Matrix_path '*'];
eval(command_text); disp(command_text);

%%% load taxa codes
taxa_file = [data_path 'teeth_taxa_table.mat'];
taxa_code = load(taxa_file);
taxa_code = taxa_code.taxa_code;
GroupSize = length(taxa_code);
% chunk_size = 55; %% PNAS
% chunk_size = 20; %% Clement
chunk_size = 25; %% HDM

% invoke process_results_cpd.m
process_cluster_cpd(cpdResultPath, outputDir, length(meshNames), cpdChunk);

% Set-up for cluster_Imprdist_landmarkfree
%%% preparation
clearvars;
close all;
path(pathdef);
addpath(path,genpath([pwd '/utils/']));

%%% pick ImprType and FeatureFix
ImprType = 'MST'; % if 'Viterbi', should also specify "ViterbiAngle"!
FeatureFix = 'off'; %% remain 'off', since 'on' can be run with cluster_FeatureFix.m

%%% setup paths
base_path = [pwd '/'];
data_path = '../data/';
rslts_path = [base_path 'impr_rslts/'];
cluster_path = [base_path 'cluster/'];
samples_path = [base_path 'samples/PNAS/'];
meshes_path = [data_path 'meshes/'];
result_path = [base_path 'results/'];
% landmarks_path = [data_path 'landmarks_clement.mat'];
TaxaCode_path = [data_path 'teeth_taxa_table.mat'];
cPMaps_path = [result_path 'cPMapsMatrix.mat'];
cPDist_path = [result_path 'cPDistMatrix.mat'];
TextureCoords1_path = [result_path 'TextureCoords1/'];
TextureCoords2_path = [result_path 'TextureCoords2/'];
% TextureCoords1_path = [pwd '/results/HDM/cPDist/TextureCoords1/'];
% TextureCoords2_path = [pwd '/results/HDM/cPDist/TextureCoords2/'];
cPLASTPath = [pwd '/results/Clement/cPDist/cPComposedLASTGraph_alpha1.mat'];

scripts_path = [cluster_path 'scripts/'];
errors_path = [cluster_path 'errors/'];
outputs_path = [cluster_path 'outputs/'];

%%% build folders if they don't exist
touch(scripts_path);
touch(errors_path);
touch(outputs_path);
touch(rslts_path);

%%% clean up paths
command_text = ['!rm -f ' scripts_path '*']; eval(command_text); disp(command_text);
command_text = ['!rm -f ' errors_path '*']; eval(command_text); disp(command_text);
command_text = ['!rm -f ' outputs_path '*']; eval(command_text); disp(command_text);
command_text = ['!rm -f ' rslts_path '*']; eval(command_text); disp(command_text);

%%% load taxa codes
taxa_code = load(TaxaCode_path);
taxa_code = taxa_code.taxa_code;
GroupSize = length(taxa_code);
% chunk_size = 55; %% PNAS
% NumLandmarks = 16; %% PNAS
% chunk_size = 20; %% Clement
% NumLandmark = 7; %% Clement
chunk_size = 25; %% HDM