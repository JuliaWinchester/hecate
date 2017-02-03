function R = rigid_motion(flatSamples, mapsMatPath)
% RIGID_MOTION - flatSamples x flatSamples cell array of rotation matrices

cpdMap = load(mapsMatPath);
if exist('cpdMap.cpMapsMatrix')
	cpdMap = cpdMap.cPMapsMatrix;
elseif exist('cpdMap.ImprMapsMatrix')
	cpdMap = cpdMap.ImprMapsMatrix;
	
R = cell(length(flatSamples));
for i = 1:length(flatSamples)
	GM = load(flatSamples{i}); GM = GM.G;
	for j = 1:length(flatSamples)
		GN = load(flatSamples{j}); GN = GN.G;
		[~, tmpR, ~] = MapToDist(GM.V, GN.V, cpdMap{i, j}, GM.Aux.VertArea);
		R{i, j} = tmpR;
	end
end

end