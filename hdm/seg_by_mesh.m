function segByMesh = seg_by_mesh(flatSamples, kIdx, vIdxCumSum)
% SEG_BY_MESH - Extract segment sub-meshes from kmeans cluster index vector

vIdxCumSum = [0; vIdxCumSum];

segByMesh = cell(length(flatSamples), 1);
for i = 1:length(flatSamples)
	segIdx = kIdx(vIdxCumSum(i)+1:vIdxCumSum(i+1));
    GM = load(flatSamples{i}); GM = GM.G;
    V = GM.V';
    F = GM.F';
    segByMesh{i}.name = GM.Aux.name;
    segByMesh{i}.segs = cell(max(segIdx), 1);
    for j = 1:size(segByMesh{i}.segs, 1)
        segByMesh{i}.segs{j}.V = V(segIdx == j, :);
        vIdx = 1:length(V);
        segVertIdxOrig = vIdx(segIdx == j);
        segVertIdxNew = 1:length(segVertIdxOrig);
        segFaceIdxOrig = F(all(ismember(F, segVertIdxOrig), 2),:);
        segFaceIdxNew = changem(segFaceIdxOrig, segVertIdxNew, segVertIdxOrig);
        segByMesh{i}.segs{j}.F = segFaceIdxNew;
    end
end

end