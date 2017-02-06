meshDir = '~/testmesh3/';
outputDir = '~/t/';
email = '';
collate_in_directories = 0;

%%% analysis control
runContinuousProcrustesDistance   = 1;
runConsistentSpectralSegmentation = 1;

%%% CPD parameters (do not change)
imprType = 'MST';
featureFix = 'off';

%%% HDM parameters
BNN = 5;
epsilon = 0.03;
FBW = 3;
fiberEps = 1e-3;
colNum = 15;
segmentNum = 15;

%%% auto set
codePath = pwd;
