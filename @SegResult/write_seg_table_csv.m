function write_seg_detail_csv(SegResult, filePath)
% WRITE_SEG_DETAIL_CSV - Write CSV with segment table

	d = SegResult.data
	meshName    = {};
	segNum      = ();
	segNFace    = ();
	segNVert    = ();
	segArea     = ();
	segPercArea = ();

	for i = 1:length(SegResult.mesh)
		for j = 1:length(SegResult.mesh{i}.segment)
			meshName = [meshName {d.meshName{i}}];
			segNum = [segNum j];
			segNFace = [segNFace size(SegResult.mesh{i}.segment{j}.F, 2)];
			segNVert = [segNFace size(SegResult.mesh{i}.segment{j}.V, 2)];
			segArea = [segArea d.segmentArea{i}(j)];
			segPercArea = [segPercArea segArea/d.segmentAreaTotal(i)]; 
		end
	end

	varNames = {'mesh_name', 'segment_id', 'n_face', 'n_vert', 'area', ...
		'proportional_area'};
	dataTable = table(meshName, segNum, segNFace, segNVert, segArea, ...
		segPercArea, 'VariableNames', varNames);
	writetable(dataTable, filepath);

end