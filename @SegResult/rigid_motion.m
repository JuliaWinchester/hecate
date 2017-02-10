function R = rigid_motion(SegResult, mapsMatPath)
% RIGID_MOTION - flatSamples x flatSamples cell array of rotation matrices

cpdMap = load(mapsMatPath);
if isfield(cpdMap, 'cpMaps')
	cpdMap = cpdMap.cpMaps;
elseif isfield(cpdMap, 'ImprMaps')
	cpdMap = cpdMap.ImprMaps;
end

R = cell(length(SegResult.mesh));
for i = 1:length(SegResult.mesh)
	for j = 1:length(SegResult.mesh)
		[~, tmpR, ~] = MapToDist(SegResult.mesh{i}.V, SegResult.mesh{j}.V, cpdMap{i, j}, SegResult.mesh{i}.Aux.VertArea);
		R{i, j} = tmpR;
	end
end

end