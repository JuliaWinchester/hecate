function cfg = get_cfg()
% GET_CFG - Returns cfg struct with fields using settings.m entries, saves it

user_settings;

% Analysis control
cfg.ctrl.runFlatten             = runFlatten;
cfg.ctrl.runListFlatMeshes		= runListFlatMeshes;
cfg.ctrl.runCPD                 = runCPD;
cfg.ctrl.runCPDImprove          = runCPDImprove;
cfg.ctrl.runSoften              = runSoften;
cfg.ctrl.runDiffMapSpectCluster = runDiffMapSpectCluster;

% Data
[meshNames, meshPaths] = get_mesh_names(meshDir, '.off');
cfg.data.meshNames = meshNames;
cfg.data.meshPaths = meshPaths;

% Misc
cfg.msc.emailAddress = email;
cfg.msc.dirCollate   = dirCollate;
cfg.msc.nMeshDisplay = meshDisplayNumber;

if strcmpi(cfg.msc.emailAddress, '')
	cfg.msc.email = 0;
else
	cfg.msc.email = 1;
end

% Params
cfg.param.chunkSize     = chunkSize;
cfg.param.imprType      = imprType;
cfg.param.featureFix    = featureFix;
cfg.param.BNN           = BNN;
cfg.param.epsilon       = epsilon;
cfg.param.FBW           = FBW;
cfg.param.fiberEps      = fiberEps;
cfg.param.eigCols       = eigCols;
cfg.param.segmentNum    = segmentNum;
cfg.param.kMeansMaxIter = kMeansMaxIter;
cfg.param.alignTeeth	= alignTeeth;

% Paths
cfg.path.meshDir           = meshDir;
cfg.path.outputDir         = outputDir;
cfg.path.cfg               = fullfile(outputDir, '/etc/cfg.mat');
cfg.path.flat              = fullfile(outputDir, '/etc/flatten/');
cfg.path.flatSample		   = fullfile(outputDir, '/etc/flatten/samples/');
cfg.path.cpd               = fullfile(outputDir, '/etc/cpd/');
cfg.path.cpdJobMats        = fullfile(outputDir, '/etc/cpd/job_mats/');
cfg.path.cpdImprove        = fullfile(outputDir, '/etc/cpd_improve/');
cfg.path.cpdImproveJobMats = fullfile(outputDir, '/etc/cpd_improve/job_mats/');
cfg.path.soften            = fullfile(outputDir, '/etc/soften/');
cfg.path.softenJobMats	   = fullfile(outputDir, '/etc/soften/job_mats/');
cfg.path.out               = fullfile(outputDir, '/results/');
