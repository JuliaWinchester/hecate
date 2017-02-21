function prepare_meshes(cfg, outputDir)
% PREPARE_MESH - Center, scale, remove zero area faces, unreferenced vertices

center = @(X) X-repmat(mean(X,2),1,size(X,2));
scale  = @(X) norm(center(X),'fro') ;

for i = 1:length(cfg.data.meshPaths)
	a = Mesh('off', cfg.data.meshPaths{i});
	a.remove_zero_area_faces();
	a.remove_unref_verts();
	a.V = center(a.V) / scale(a.V);
	fileName = strsplit(cfg.data.meshPaths{i}, filesep);
	fileName = fileName{end};
	fileName = [fileName(1:end-4) '_n0f_urv_cs.off'];
	disp(fileName);
	write_off(fullfile(outputDir, fileName), a.V, a.F);
end
