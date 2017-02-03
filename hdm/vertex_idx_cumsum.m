function [vIdxCumSum, vIdxArray] = vertex_idx_cumsum(meshPaths)
% VERTEX_IDX_CUMSUM - Vertex index delimits by mesh for concatenated @Meshs

n = length(meshPaths);
nVertList = zeros(n, 1);
vIdxArray = zeros(n+1, 2);
for i=1:n
    tmp = load(meshPaths{i});
    nVertList(i) = tmp.G.nV;
    vIdxArray(i+1, 1) = vIdxArray(i, 2) + 1;
    vIdxArray(i+1, 2) = vIdxArray(i+1, 1) + tmp.G.nV-1;
end
vIdxArray(1,:) = [];
vIdxCumSum = cumsum(nVertList);

end