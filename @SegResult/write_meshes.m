function write_meshes(SegResult, dirPath)
% WRITE_MESHES - Save mesh files
	
	touch(dirPath);

	for i = 1:length(SegResult.mesh)
		disp(['Saving mesh ' SegResult.mesh{i}.Aux.name ' as OFF file...']);
		write_off(fullfile(dirPath, [SegResult.mesh{i}.Aux.name '.off']), ... 
			SegResult.mesh{i}.V, SegResult.mesh{i}.F);
	end
	
end