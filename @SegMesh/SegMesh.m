classdef SegMesh < Mesh
% Class inheriting Mesh with extra property to store segment data

	properties
		segment = {};
	end

	methods

		function obj = SegMesh(meshObj)
			obj@Mesh(meshObj);
		end

	end

end