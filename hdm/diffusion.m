function [H, diffMatrixSize] = diffusion(BNN, BaseEps, vIdxCumSum, flatSamples, distMatPath, softenPath, chunkSize)
% DIFFUSION - Build diffusion kernal matrix from distance matrix

%% process base diffusion
tmp = load(distMatPath);
n = size(tmp.cpDist, 1);
baseDistMatrix = tmp.cpDist;
baseDistMatrix = baseDistMatrix-diag(diag(baseDistMatrix));

%%% only connect BNN-nearest-neighbors
[sDists,rowNNs] = sort(baseDistMatrix, 2);
sDists = sDists(:,2:(1+BNN));
rowNNs = rowNNs(:,2:(1+BNN));
baseWeights = sparse(repmat((1:n)' ,1 , BNN),rowNNs , sDists, n, n);
baseWeights = min(baseWeights, baseWeights');
for i = 1:n
    sDists(i,:) = baseWeights(i, rowNNs(i,:));
end
sDists = exp(-sDists.^2/BaseEps);

%% build diffusion kernel matrix
diffMatrixSize = vIdxCumSum(end);
diffMatrixSizeList = [0; vIdxCumSum];
diffMatrixSizeList(end) = []; % treated as block shifts
diffMatrixRowIdx = [];
diffMatrixColIdx = [];
diffMatrixVal = [];

cBack = 0;
for j = 1:n
    G1 = load(flatSamples{j}); G1 = G1.G;
    for nns = 1:BNN
        if (sDists(j, nns) == 0)
            continue;
        end
        k = rowNNs(j, nns);
        G2 = load(flatSamples{k}); G2 = G2.G;
        
        %%% load texture coordinates
        load(fullfile(softenPath, ['soften_mat_' num2str(chunk_idx(j, k, n, )) '.mat']));
        AugKernel12 = cPSoftMapsMatrix{j, k};

        % Is the next bit meant to be repeated?        
        [rowIdx, colIdx, val] = find(AugKernel12);
        diffMatrixRowIdx = [diffMatrixRowIdx; rowIdx+diffMatrixSizeList(j)];
        diffMatrixColIdx = [diffMatrixColIdx; colIdx+diffMatrixSizeList(k)];
        diffMatrixVal = [diffMatrixVal; sDists(j, nns)*val];

        [rowIdx, colIdx, val] = find(AugKernel12');
        diffMatrixRowIdx = [diffMatrixRowIdx; rowIdx+diffMatrixSizeList(k)];
        diffMatrixColIdx = [diffMatrixColIdx; colIdx+diffMatrixSizeList(j)];
        diffMatrixVal = [diffMatrixVal; sDists(j, nns)*val];

    end
    for cc=1:cBack
        fprintf('\b');
    end
    cBack = fprintf(['%4d/' num2str(groupSize) ' done.\n'],j);
end

H = sparse(diffMatrixRowIdx,diffMatrixColIdx,diffMatrixVal,diffMatrixSize,diffMatrixSize);

end 