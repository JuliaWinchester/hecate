function rigid_motion(SegResult)
% RIGID_MOTION - flatSamples x flatSamples cell array of rotation matrices

mapsMatPath = fullfile(SegResult.cfg.path.cpdImprove, 'cpMapsMatrix_MST.mat');

cpdMap = load(mapsMatPath);
if isfield(cpdMap, 'cpMaps')
	cpdMap = cpdMap.cpMaps;
elseif isfield(cpdMap, 'ImprMaps')
	cpdMap = cpdMap.ImprMaps;
end

SegResult.R = cell(length(SegResult.mesh));
for i = 1:length(SegResult.mesh)
	for j = 1:length(SegResult.mesh)
		[~, tmpR, ~] = MapToDist(SegResult.mesh{i}.V, SegResult.mesh{j}.V, cpdMap{i, j}, SegResult.mesh{i}.Aux.VertArea);
		SegResult.R{i, j} = tmpR;
	end
end

end