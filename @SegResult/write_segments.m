function write_segments(SegResult, dirPath, subdirByMesh)
% WRITE_SEGMENTS - Save segment meshes
	
	touch(dirPath);
	if subdirByMesh
		n = cellfun(@(x) x.Aux.name, SegResult.mesh, 'UniformOutput', 0);
		n = strrep(n, '.', '_');
		d = cellfun(@(x) fullfile(dirPath, x), n, 'UniformOutput', 0);
		cellfun(@touch, d);
	else
		d = repmat({dirPath}, 1, length(SegResult.mesh));
	end
		
	for i = 1:length(SegResult.mesh)
		disp(['Saving segments for mesh ' SegResult.mesh{i}.Aux.name '...']);
		for j = 1:length(SegResult.mesh{i}.segment)
			write_off(fullfile(d{i}, ... 
				[SegResult.mesh{i}.Aux.name '_seg' num2str(j) '.off']), ....
				SegResult.mesh{i}.segment{j}.V, ...
				SegResult.mesh{i}.segment{j}.F);
		end
	end

end