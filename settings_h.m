meshDir = '~/pnas_auto3dgm_data/';
outputDir = '~/p/';
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
eigCols = 15;
segmentNum = 15;
chunkSize = 25;
kMeansMaxIter = 1000;

%%% auto set
codePath = pwd;
