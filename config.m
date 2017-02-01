meshDir = '~/testmesh3/';
outputDir = '~/t/';
email = '';

%%% analysis control
runContinuousProcrustesDistance   = 1;
runConsistentSpectralSegmentation = 1;

%%% HDM parameters
BNN = 5;
epsilon = 0.5;
FBW = 3;
delta = 0.5;
colNum = 15;
segmentNum = 15;

%%% auto set
codePath = pwd;
