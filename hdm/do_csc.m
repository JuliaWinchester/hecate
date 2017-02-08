function idx = csc(cfg, U, sqrtInvD)
% CSC - Consistent spectral clustering of surface regions

nSegments     = cfg.param.segmentNum;
eigCols       = cfg.param.eigCols;
kMeansMaxIter = cfg.param.kMeansMaxIter;

sqrtInvD(isinf(sqrtInvD)) = 0;
SignVectors = sqrtInvD*U(:, 2:(eigCols+1));
idx = kmeans(SignVectors, nSegments, 'MaxIter', kMeansMaxIter);

%%% TODO: some idx might be +/-Inf, since sqrtInvD might contain +/-Inf
%%% better insert a piece of code here assigning a non-nan label to +/-Inf
%%% points in idx
[InfIdx,~] = find(isinf(SignVectors));
InfIdx = unique(InfIdx);
for j=1:length(InfIdx)
    IdxJ = find(nVListCumsum>=InfIdx(j),1);
    load(flatSamples{IdxJ});
    ValidVList = 1:G.nV;
    IdxOnG = idx(namesDelimit(IdxJ,1):namesDelimit(IdxJ,2));
    ValidVList(IdxOnG == idx(InfIdx(j))) = [];
    tmpDistMatrix = pdist2(G.V(:,InfIdx(j)-namesDelimit(IdxJ,1)+1)',G.V(:,ValidVList)');
    [~,minInd] = min(tmpDistMatrix);
    idx(InfIdx(j)) = idx(ValidVList(minInd)+namesDelimit(IdxJ,1)-1);
end

end