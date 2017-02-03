function segment(flatSamples, softenPath, distMatPath, nSegments, baseEps, BNN, eigCols, kMeansMaxIter, chunkSize)
% SEGMENT - Consistent spectral clustering of mesh surface regions

[vIdxCumSum, vIdxArray] = vertex_idx_cumsum(flatSamples);

%% collection rigid motions /// Need to change this to generate rigid motions
rigid_motions = load([data_path 'rigid_motion_mats.mat']);
options.R = rigid_motions;

[H, diffMatrixSize] = diffusion(BNN, BaseEps, vIdxCumSum, flatSamples, distMatPath, softenPath, chunkSize);

[U, ~, sqrtInvD] = eigen_decomp(H, diffMatrixSize);

%==========================================================================
%%% consistent spectral clustering on each surface
%==========================================================================

idx = csc(15, sqrtInvD, U, 14);

ViewBundleFunc(Names,idx,options);

% JMW additions to extract segments as needed
idxByMesh = cell(groupSize, 1);
nVListCumsum2 = [0; nVListCumsum];
for i = 1:(length(nVListCumsum2) - 1)
    idxByMesh{i} = idx(nVListCumsum2(i) + 1:nVListCumsum2(i+1));
end

segByMesh = cell(length(Names), 1);
for i = 1:length(Names)
    GM = load(fullfile(sample_path, [Names{i} '.mat']));
    GM = GM.G;
    V = GM.V';
    F = GM.F';
    segByMesh{i}.name = GM.Aux.name;
    segByMesh{i}.segs = cell(15, 1);
    for j = 1:15
        segByMesh{i}.segs{j}.V = V(idxByMesh{i} == j, :);
        vertIdx = 1:length(V);
        segOrigVertIdx = vertIdx(idxByMesh{i} == j);
        segNewVertIdx = 1:length(segOrigVertIdx);
        origIdxF = F(all(ismember(F,segOrigVertIdx),2),:);
        newIdxF = changem(origIdxF, segNewVertIdx, segOrigVertIdx);
        segByMesh{i}.segs{j}.F = newIdxF;
        disp(['~/code/hecate/data/segs/' Names{i} '_seg' num2str(j) '.off']);
        write_off(['~/code/hecate/data/segs/' Names{i} '_seg' num2str(j) '.off'], segByMesh{i}.segs{j}.V, segByMesh{i}.segs{j}.F);
    end
end