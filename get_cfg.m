function cfg = get_cfg()
% GET_CFG - Returns cfg struct with fields using settings.m entries, saves it

user_settings;

% Analysis control
cfg.ctrl.restartAll				= restartAll;
cfg.ctrl.runFlatten             = runFlatten;
cfg.ctrl.runListFlatMeshes		= runListFlatMeshes;
cfg.ctrl.runCPD                 = runCPD;
cfg.ctrl.runCPDMST              = runCPDMST;
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
cfg.param.alignTeeth	          = alignTeeth;
cfg.param.colorSegments			  = colorSegments;
cfg.param.chunkSize               = chunkSize;
cfg.param.flat.confMaxLocalWidth  = confMaxLocalWidth;
cfg.param.flat.gaussMaxLocalWidth = gaussMaxLocalWidth;
cfg.param.flat.gaussMinLocalWidth = gaussMinLocalWidth;
cfg.param.flat.adMaxLocalWidth    = adMaxLocalWidth;
cfg.param.cpd.featureType         = featureType;
cfg.param.cpd.numFeatureMatch     = numFeatureMatch;
cfg.param.cpdi.imprType           = imprType;
cfg.param.cpdi.featureFix         = featureFix;
cfg.param.diff.BNN                = BNN;
cfg.param.diff.epsilon            = epsilon;
cfg.param.diff.FBW                = FBW;
cfg.param.diff.fiberEps           = fiberEps;
cfg.param.spec.eigCols            = eigCols;
cfg.param.spec.segmentNum         = segmentNum;
cfg.param.spec.kMeansMaxIter      = kMeansMaxIter;

% Paths
cfg.path.meshDir           = meshDir;
cfg.path.outputDir         = outputDir;
cfg.path.cfg               = fullfile(outputDir, '/etc/cfg.mat');
cfg.path.flat              = fullfile(outputDir, '/etc/flatten/');
cfg.path.flatSample		   = fullfile(outputDir, '/etc/flatten/samples/');
cfg.path.cpd               = fullfile(outputDir, '/etc/cpd/');
cfg.path.cpdJobMats        = fullfile(outputDir, '/etc/cpd/job_mats/');
cfg.path.cpdMST            = fullfile(outputDir, '/etc/cpd_mst/');
cfg.path.soften            = fullfile(outputDir, '/etc/soften/');
cfg.path.softenJobMats	   = fullfile(outputDir, '/etc/soften/job_mats/');
cfg.path.out               = fullfile(outputDir, '/results/');
