classdef SegResult < handle
% Class storing results from consistent spectral clustering of surface regions
% and methods to export these results

	properties
	% Documentation needed
		cfg = struct;
		data = struct;
		mesh = {};
		R = {};
	end

	methods

		function obj = SegResult(flatSamples, kIdx, vIdxCumSum, cfg)
		% Class constructor
		
			vIdxCumSum = [0; vIdxCumSum];
			for i = 1:length(flatSamples)
				obj.mesh{i}.segmentIdx = kIdx(vIdxCumSum(i)+1:vIdxCumSum(i+1));
			    tmp = load(flatSamples{i}); 
			    obj.mesh{i} = SegMesh(tmp.G);
			    obj.mesh{i}.segment = cell(max(obj.mesh{i}.segmentIdx), 1);
			    V = obj.mesh{i}.V';
			    F = obj.mesh{i}.F';
			    for j = 1:size(obj.mesh{i}.segment, 1)
			        obj.mesh{i}.segment{j}.V = ...
			        	V(obj.mesh{i}.segmentIdx == j, :)';
			        vIdx = 1:length(V);
			        segVertIdxOrig = vIdx(obj.mesh{i}.segmentIdx == j);
			        segVertIdxNew = 1:length(segVertIdxOrig);
			        segFaceIdxOrig = F(all(ismember(F, segVertIdxOrig), 2),:);
			        segFaceIdxNew = changem(segFaceIdxOrig, segVertIdxNew, ...
			        	segVertIdxOrig);
			        obj.mesh{i}.segment{j}.F = segFaceIdxNew';
			    end
			end
			obj.cfg = cfg;
			
		end

	end
end