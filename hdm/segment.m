function segment(flatSamples, softenPath, baseEps, BNN, fiberEps, distMatPath, featureFix, chunkSize)
% SEGMENT - Consistent spectral clustering of mesh surface regions

%% useful inline functions
ChunkIdx = @(TAXAind1,TAXAind2) ceil(((TAXAind1-1)*groupSize+TAXAind2)/ChunkSize);

%% parse GroupNames
[~,ClTable,~] = xlsread(spreadsheet_path);
Names = {}; % This is all specimens, probably best given as meshnames or meshpaths? flatsamples
NamesByGroup = cell(1,length(GroupNames)); % This is specimens by genus group, getting rid of this

groupSize = length(flatSamples);
diffMatrixSizeList = zeros(groupSize,1);
TAXAinds = (1:groupSize)';
namesDelimit = zeros(groupSize+1,2);
for j=1:groupSize
    tmp = load(flatSamples{j});
    diffMatrixSizeList(j) = tmp.G.nV;
    namesDelimit(j+1,1) = namesDelimit(j,2)+1;
    namesDelimit(j+1,2) = namesDelimit(j+1,1)+G.nV-1;
end
namesDelimit(1,:) = [];
nVList = diffMatrixSizeList;
nVListCumsum = cumsum(nVList);

%% collection rigid motions /// Need to change this to generate rigid motions
rigid_motions = load([data_path 'rigid_motion_mats.mat']);
options.R = rigid_motions;

%% process base diffusion
tmp = load(distMatPath);
baseDistMatrix = tmp.cpDist;
baseDistMatrix = baseDistMatrix-diag(diag(baseDistMatrix));

%%% only connect BNN-nearest-neighbors
[sDists,rowNNs] = sort(baseDistMatrix,2);
sDists = sDists(:,2:(1+BNN));
rowNNs = rowNNs(:,2:(1+BNN));
baseWeights = sparse(repmat((1:groupSize)',1,BNN),rowNNs,sDists,groupSize,groupSize);
baseWeights = min(baseWeights, baseWeights');
for j=1:groupSize
    sDists(j,:) = baseWeights(j,rowNNs(j,:));
end
sDists = exp(-sDists.^2/BaseEps);

%% build diffusion kernel matrix
diffMatrixSize = sum(diffMatrixSizeList);
diffMatrixSizeList = cumsum(diffMatrixSizeList);
diffMatrixSizeList = [0; diffMatrixSizeList];
diffMatrixSizeList(end) = []; % treated as block shifts
diffMatrixRowIdx = [];
diffMatrixColIdx = [];
diffMatrixVal = [];

cBack = 0;
for j=1:groupSize
    G1 = load(flatSamples{j}); G1 = G1.G;
    for nns = 1:BNN
        if (sDists(j,nns) == 0)
            continue;
        end
        k = rowNNs(j,nns);
        G2 = load(flatSamples{k}); G2 = G2.G;
        
        %%% load texture coordinates
        TAXAind1 = j;
        TAXAind2 = k;
        load(fullfile(softenPath, ['soften_mat_' num2str(ChunkIdx(j, k)) '.mat']));
        AugKernel12 = cPSoftMapsMatrix{j, k};

        % Is the next bit meant to be repeated?        
        [rowIdx, colIdx, val] = find(AugKernel12);
        diffMatrixRowIdx = [diffMatrixRowIdx; rowIdx+diffMatrixSizeList(j)];
        diffMatrixColIdx = [diffMatrixColIdx; colIdx+diffMatrixSizeList(k)];
        diffMatrixVal = [diffMatrixVal; sDists(j,nns)*val];

        [rowIdx, colIdx, val] = find(AugKernel12');
        diffMatrixRowIdx = [diffMatrixRowIdx; rowIdx+diffMatrixSizeList(k)];
        diffMatrixColIdx = [diffMatrixColIdx; colIdx+diffMatrixSizeList(j)];
        diffMatrixVal = [diffMatrixVal; sDists(j,nns)*val];

    end
    for cc=1:cBack
        fprintf('\b');
    end
    cBack = fprintf(['%4d/' num2str(groupSize) ' done.\n'],j);
end

H = sparse(diffMatrixRowIdx,diffMatrixColIdx,diffMatrixVal,diffMatrixSize,diffMatrixSize);
clear diffMatrixColIdx diffMatrixRowIdx diffMatrixVal rowIdx colIdx val
clear tc1 tc2

%% eigen-decomposition
sqrtD = sparse(1:diffMatrixSize,1:diffMatrixSize,sqrt(sum(H)));
invD = sparse(1:diffMatrixSize,1:diffMatrixSize,1./sum(H));
sqrtInvD = sparse(1:diffMatrixSize,1:diffMatrixSize,1./sqrt(sum(H)));
H = sqrtInvD*H*sqrtInvD;
H = (H+H')/2;

eigopt = struct('isreal',1,'issym',1,'maxit',5000,'disp',0);
tic;
[U, lambda] = eigs(H, 101, 'LM', eigopt);
lambda = diag(lambda);
disp(['Eigs completed in ' num2str(toc) ' seconds']);
clear H

%==========================================================================
%%% consistent spectral clustering on each surface
%==========================================================================
sqrtInvD(isinf(sqrtInvD)) = 0; % Previously in HBDM section, not sure if needed?
SignVectors = sqrtInvD*U(:,2:15);
% SignVectors(abs(SignVectors)<1e-10) = 0;
% SignVectors = sign(SignVectors);
idx = kmeans(SignVectors,15,'MaxIter',1000);
%%% TODO: some idx might be +/-Inf, since sqrtInvD might contain +/-Inf
%%% better insert a piece of code here assigning a non-nan label to +/-Inf
%%% points in idx
[InfIdx,~] = find(isinf(SignVectors));
InfIdx = unique(InfIdx);
for j=1:length(InfIdx)
    IdxJ = find(nVListCumsum>=InfIdx(j),1);
    NamesJ = Names{IdxJ};
    load([sample_path NamesJ '.mat']);
    ValidVList = 1:G.nV;
    IdxOnG = idx(namesDelimit(IdxJ,1):namesDelimit(IdxJ,2));
    ValidVList(IdxOnG == idx(InfIdx(j))) = [];
    tmpDistMatrix = pdist2(G.V(:,InfIdx(j)-namesDelimit(IdxJ,1)+1)',G.V(:,ValidVList)');
    [~,minInd] = min(tmpDistMatrix);
    idx(InfIdx(j)) = idx(ValidVList(minInd)+namesDelimit(IdxJ,1)-1);
end
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