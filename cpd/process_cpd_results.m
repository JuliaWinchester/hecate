function resultPath = process_cpd_results(jobMatPath, outputDir, meshNum, chunkSize, fileSuffix)
% PROCESS_CPD_RESULTS - Map, distance, and texture coords from cpd job matrices

if nargin == 4
    fileSuffix = '';
end

resultPath = fullfile(outputDir, '/etc/cpd/');
tc1Path = fullfile(resultPath, '/texture_coords_1/');
tc2Path = fullfile(resultPath, '/texture_coords_2/');

%%% read rslt matrices and separate distance and landmarkMSE's
cpDist = zeros(meshNum);
cpMaps = cell(meshNum);
cpMapsInv = cell(meshNum);
tc1Temp = cell(meshNum);
tc2Temp = cell(meshNum);

cnt = 0;
job_id = 0;
for k1=1:meshNum
    progressbar(k1,meshNum,20);
    for k2=1:meshNum
        if mod(cnt,chunkSize)==0
            job_id = job_id+1;
            load(fullfile(jobMatPath, ['rslt_mat_' num2str(job_id)]));
        end
        if exist('cPrslt')
            cpDist(k1,k2) = cPrslt{k1,k2}.cPdist;
            cpMaps{k1,k2} = cPrslt{k1,k2}.cPmap;
            cpMapsInv{k1,k2} = cPrslt{k1,k2}.invcPmap;
            tc1Temp{k1,k2} = cPrslt{k1,k2}.TextureCoords1;
            tc2Temp{k1,k2} = cPrslt{k1,k2}.TextureCoords2;
        elseif exist('Imprrslt')
            cpDist(k1,k2) = Imprrslt{k1,k2}.ImprDist;
            cpMaps{k1,k2} = Imprrslt{k1,k2}.ImprMap;
            cpMapsInv{k1,k2} = Imprrslt{k1,k2}.invImprMap;
            tc1Temp{k1,k2} = Imprrslt{k1,k2}.TextureCoords1;
            tc2Temp{k1,k2} = Imprrslt{k1,k2}.TextureCoords2;
        end
            
        
        cnt = cnt+1;
    end
end

%%% symmetrize
cnt = 0;
job_id = 0;
for j=1:meshNum
    progressbar(j,meshNum,20);
    for k=1:meshNum
        if mod(cnt,chunkSize)==0
            if cnt>0
                save(fullfile(tc1Path, ...
                    ['TextureCoords1_mat_' num2str(job_id) '.mat']), ... 
                    'tc1');
                save(fullfile(tc2Path, ...
                    ['TextureCoords2_mat_' num2str(job_id) '.mat']), ...
                    'tc2');
                clear tc1 tc2;
            end
            job_id = job_id+1;
            tc1 = cell(meshNum,meshNum);
            tc2 = cell(meshNum,meshNum);
        end
        if cpDist(j,k)<cpDist(k,j)
            cpMaps{k,j} = cpMapsInv{j,k};
            tc1{j,k} = tc1Temp{j,k};
            tc2{j,k} = tc2Temp{j,k};
        else
            cpMaps{j,k} = cpMapsInv{k,j};
            tc1{j,k} = tc2Temp{k,j};
            tc2{j,k} = tc1Temp{k,j};
        end
        cnt = cnt+1;
    end
end
% if mod(cnt,chunkSize)~=0
save(fullfile(tc1Path, ['TextureCoords1_mat_' num2str(job_id) '.mat']), ... 
    'tc1');
save(fullfile(tc2Path, ['TextureCoords2_mat_' num2str(job_id) '.mat']), ...
    'tc2');
clear tc1 tc2;
% end
cpDist = min(cpDist,cpDist');

%%% visualize distance and landmarkMSE matrices
figure;
imagesc(cpDist./max(cpDist(:))*64);
axis equal;
axis([1,meshNum,1,meshNum]);

%%% save results
save(fullfile(resultPath, ['cpDistMatrix' fileSuffix '.mat']), 'cpDist');
save(fullfile(resultPath, ['cpMapsMatrix' fileSuffix '.mat']), 'cpMaps');

end
