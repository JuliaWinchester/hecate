function write_seg_group(SegResult, filePath, nRow, alignTeeth)
% Creates and saves a mesh combining all segments from all meshes for comparison

	if alignTeeth
		R = SegResult.rigid_motion();
		newMesh = cell(length(SegResult.mesh), 1);
		for i = 1:length(SegResult.mesh)
			newMesh{i}.V = R{i, 1} * SegResult.mesh{i}.V;
			if det(R{i, 1}) < 0
				newMesh{i}.F = flipud(SegResult.mesh{i}.F);
			else
				newMesh{i}.F = SegResult.mesh{i}.F;
			end
			for j = 1:length(SegResult.mesh{i}.segment)
				newMesh{i}.segment{j}.V = R{i, 1} * SegResult.mesh{i}.segment{j}.V;
				if det(R{i, 1}) < 0
					newMesh{i}.segment{j}.F = flipud(SegResult.mesh{i}.segment{j}.F);
				else
					newMesh{i}.segment{j}.F = SegResult.mesh{i}.segment{j}.F;
				end
			end
		end
	else
		newMesh = SegResult.mesh;
	end

	nMesh = length(newMesh);
	nRow = floor(sqrt(nMesh));
	nCol = ceil(nMesh/nRow);
	xMax = max(cellfun(@(m) max(m.V(1, :)) - min(m.V(1, :)), newMesh));
	yMax = max(cellfun(@(m) max(m.V(2, :)) - min(m.V(2, :)), newMesh));
	xStep = xMax * 1.25;
	yStep = yMax * 1.25;

	% Locations of meshes
	xLocs = repmat(0:xStep:xStep*(nCol-1), 1, nRow);
	yLocs = reshape(repmat(0:yStep:yStep*(nRow-1), nCol, 1), [1, nRow*nCol]);
	zLocs = zeros(1, nRow * nCol);
	locs = vertcat(xLocs, yLocs, zLocs);

	groupV = [];
	groupF = [];
	for i = 1:length(newMesh)
		vectCenter = mean(newMesh{i}.V, 2);
		vectLoc = locs(:, i) - vectCenter;
		for j = 1:length(newMesh{i}.segment)
			movedV = newMesh{i}.segment{j}.V + vectLoc;
			groupF = [groupF newMesh{i}.segment{j}.F+length(groupV)];
			groupV = [groupV movedV];
		end
	end

	write_off(fullfile(filePath), groupV, groupF);

end

