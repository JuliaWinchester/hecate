%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% User settings
%%%%
%%%% Instructions: Edit values in this file to control software behavior. This 
%%%% is the only file users should edit.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Destroy any and all configuration and data files from previous analyses
% If off, partially complete analysis can be resumed
restartAll = 0;

% Directory of input mesh files
meshDir = '~/pnas_plat/';

% Directory for output files
outputDir = '/gtmp/hecate/';

% Optional email for alerting when cluster jobs finish
email = '';

% Align teeth when exporting files (only affects exported files, not analysis)
alignTeeth = 1;

% Collate saved segments by mesh dir (i.e., mesh1/mesh1_seg1.off)
dirCollate = 0;

% Whether output segment files should be colored to differentiate them
colorSegments = 1;

% How many meshes to display segments from in representative MATLAB figure
meshDisplayNumber = 10;

% Cluster file block size (don't change)
chunkSize = 50;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Analysis parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Continuous Procrustes distance parameters (don't change)

% flatten
confMaxLocalWidth = 8;
gaussMaxLocalWidth = 10;
gaussMinLocalWidth = 6;
adMaxLocalWidth = 7;

% cpd
featureType = 'ConfMax';
numFeatureMatch = 4;

% cpd_improve
imprType = 'MST';
featureFix = 'off';

%% Diffusion map parameters
BNN = 5; % usually 5
epsilon = 0.03;
FBW = 3;
fiberEps = 1e-3;

%% Consistent spectral clustering parameters
segmentNum = 15;
eigCols = 15;
kMeansMaxIter = 1000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Analysis control (change to run only some analysis steps)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Continuous Procrustes distance
runFlatten = 0;
runListFlatMeshes = 0;
runCPD = 0;
runCPDMST = 1;

% Diffusion map/spectral clustering
runSoften = 1;
runDiffMapSpectCluster = 1;
