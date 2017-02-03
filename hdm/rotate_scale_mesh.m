function V = align_mesh(V, R, rotateBool, scaleBool)
% ALIGN_MESH - Centers, scales, and rotates mesh

V = V - repmat(mean(V, 2), 1, size(V,2));
V = R * (V / norm(V, 'fro'));

end