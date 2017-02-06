function cfg = get_cfg(cfgSave)
% GET_CFG - Returns cfg struct with fields using settings.m entries, saves it

settings;

% Data
[meshNames, meshPaths] = get_mesh_names(meshDir, '.off');
cfg.data.meshNames = meshNames;
cfg.data.meshPaths = meshPaths;

% Misc
cfg.msc.email      = email;
cfg.msc.dirCollate = collate_in_directories;

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

% Paths
cfg.path.meshDir           = meshDir;
cfg.path.outputDir         = outputDir;
cfg.path.cfg               = fullfile(outputDir, '/etc/cfg.mat');
cfg.path.flat              = fullfile(outputDir, '/etc/flatten/');
cfg.path.cpd               = fullfile(outputDir, '/etc/cpd/');
cfg.path.cpdJobMats        = fullfile(outputDir, '/etc/cpd/job_mats/');
cfg.path.cpdImprove        = fullfile(outputDir, '/etc/cpd_improve/');
cfg.path.cpdImproveJobMats = fullfile(outputDir, '/etc/cpd_improve/job_mats/');
cfg.path.soften            = fullfile(outputDir, '/etc/soften/');
cfg.path.softenJobMats	   = fullfile(outputDir, '/etc/soften/job_mats/')
cfg.path.out               = fullfile(outputDir, '/output/');
cfg.path.segments          = fullfile(outputDir, '/output/segments/');

if cfgSave
	save(cfg.path.cfgPath, 'cfg');
end