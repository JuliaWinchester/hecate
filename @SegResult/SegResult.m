classdef SegResult < handle
% Class storing results from consistent spectral clustering of surface regions
% and methods to export these results

	properties
	% Documentation needed
		mesh = {};
	end

	methods

		function obj = SegResult(flatSamples, kIdx, vIdxCumSum)
		% Class constructor
		
			vIdxCumSum = [0; vIdxCumSum];
			for i = 1:length(flatSamples)
				segIdx = kIdx(vIdxCumSum(i)+1:vIdxCumSum(i+1));
			    tmp = load(flatSamples{i}); 
			    obj.mesh{i} = SegMesh(tmp.G);
			    obj.mesh{i}.segment = cell(max(segIdx), 1);
			    V = obj.mesh{i}.V';
			    F = obj.mesh{i}.F';
			    for j = 1:size(obj.mesh{i}.segment, 1)
			        obj.mesh{i}.segment{j}.V = V(segIdx == j, :);
			        vIdx = 1:length(V);
			        segVertIdxOrig = vIdx(segIdx == j);
			        segVertIdxNew = 1:length(segVertIdxOrig);
			        segFaceIdxOrig = F(all(ismember(F, segVertIdxOrig), 2),:);
			        segFaceIdxNew = changem(segFaceIdxOrig, segVertIdxNew, segVertIdxOrig);
			        obj.mesh{i}.segment{j}.F = segFaceIdxNew;
			    end
			end
		
		end

	end
end