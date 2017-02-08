function write_seg_group(SegResult, filePath, nRow)
% Creates and saves a mesh combining all segments from all meshes for comparison

	nMesh = length(SegResult.mesh);
	nCol = ceil(nMesh/nRow);
	xMax = 5; % Calc this
	yMax = 5; % Same
	xStep = xMax * 1.25;
	yStep = yMax * 1.25;

	xCenter = repmat(0:xStep:xStep*(nCol-1), nRow, 1);
	yCenter = repmat((0:yStep:yStep*(nRow-1))', nCol, 1);
	zCenter = zeros(nRow, nCol);
	center = cat(3, xCenter, yCenter, zCenter);

	% For each mesh, calc value to center + push mesh as center matrix describes

	% For each segment of each mesh, push as needed

	% Concatenate all vertex segments and face connectivity into big kludge

	% Save kludge mesh
end

