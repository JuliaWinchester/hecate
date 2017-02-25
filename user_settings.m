%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% User settings
%%%%
%%%% Instructions: Edit values in this file to control software behavior. This 
%%%% is the only file users should edit.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Directory of input mesh files
meshDir = '~/pnas_plat/';

% Directory for output files
outputDir = '~/pnas_plat_out/';

% Optional email for alerting when cluster jobs finish
email = 'julia.m.winchester@gmail.com';

% Align teeth when exporting files (only affects exported files, not analysis)
alignTeeth = 1;

% Collate saved segments by mesh dir (i.e., mesh1/mesh1_seg1.off)
dirCollate = 0;

% How many meshes to display segments from in representative MATLAB figure
meshDisplayNumber = 10;

% Cluster file block size (don't change)
chunkSize = 50;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Analysis parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Continuous Procrustes distance parameters (don't change)
imprType = 'MST';
featureFix = 'off';

% Diffusion map parameters
BNN = 5; % usually 5
epsilon = 0.03;
FBW = 3;
fiberEps = 1e-3;

% Consistent spectral clustering parameters
segmentNum = 15;
eigCols = 15;
kMeansMaxIter = 1000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Analysis control (change to run only some analysis steps)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Continuous Procrustes distance
runFlatten = 0;
runListFlatMeshes = 1;
runCPD = 1;
runCPDImprove = 1;

% Diffusion map/spectral clustering
runSoften = 1;
runDiffMapSpectCluster = 1;
