function resultPath = process_cluster_cpd(jobMatPath, outputDir, meshNum, chunkSize)
% PROCESS_RESULTS_CPD - Map, distance, and texture coords from cpd job matrices

resultPath = fullfile(outputDir, '/etc/cpd/');
tc1Path = fullfile(resultPath, '/texture_coords_1/');
tc2Path = fullfile(resultPath, '/texture_coords_2/');

%%% read rslt matrices and separate distance and landmarkMSE's
cPDistMatrix = zeros(meshNum);
cPMapsMatrix = cell(meshNum);
invcPMapsMatrix = cell(meshNum);
tmpTextureCoords1Matrix = cell(meshNum);
tmpTextureCoords2Matrix = cell(meshNum);

cnt = 0;
job_id = 0;
for k1=1:meshNum
    progressbar(k1,meshNum,20);
    for k2=1:meshNum
        if mod(cnt,chunkSize)==0
            job_id = job_id+1;
            load(fullfile(jobMatPath, ['rslt_mat_' num2str(job_id)]));
        end
        cPDistMatrix(k1,k2) = cPrslt{k1,k2}.cPdist;
        cPMapsMatrix{k1,k2} = cPrslt{k1,k2}.cPmap;
        invcPMapsMatrix{k1,k2} = cPrslt{k1,k2}.invcPmap;
        tmpTextureCoords1Matrix{k1,k2} = cPrslt{k1,k2}.TextureCoords1;
        tmpTextureCoords2Matrix{k1,k2} = cPrslt{k1,k2}.TextureCoords2;
        
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
                    'TextureCoords1Matrix');
                save(fullfile(tc2Path, ...
                    ['TextureCoords2_mat_' num2str(job_id) '.mat']), ...
                    'TextureCoords2Matrix');
                clear TextureCoords1Matrix TextureCoords2Matrix;
            end
            job_id = job_id+1;
            TextureCoords1Matrix = cell(meshNum,meshNum);
            TextureCoords2Matrix = cell(meshNum,meshNum);
        end
        if cPDistMatrix(j,k)<cPDistMatrix(k,j)
            cPMapsMatrix{k,j} = invcPMapsMatrix{j,k};
            TextureCoords1Matrix{j,k} = tmpTextureCoords1Matrix{j,k};
            TextureCoords2Matrix{j,k} = tmpTextureCoords2Matrix{j,k};
        else
            cPMapsMatrix{j,k} = invcPMapsMatrix{k,j};
            TextureCoords1Matrix{j,k} = tmpTextureCoords2Matrix{k,j};
            TextureCoords2Matrix{j,k} = tmpTextureCoords1Matrix{k,j};
        end
        cnt = cnt+1;
    end
end
% if mod(cnt,chunkSize)~=0
save(fullfile(tc1Path, ['TextureCoords1_mat_' num2str(job_id) '.mat']), ... 
    'TextureCoords1Matrix');
save(fullfile(tc2Path, ['TextureCoords2_mat_' num2str(job_id) '.mat']), ...
    'TextureCoords2Matrix');
clear TextureCoords1Matrix TextureCoords2Matrix;
% end
cPDistMatrix = min(cPDistMatrix,cPDistMatrix');

%%% visualize distance and landmarkMSE matrices
figure;
imagesc(cPDistMatrix./max(cPDistMatrix(:))*64);
axis equal;
axis([1,meshNum,1,meshNum]);

%%% save results
save(fullfile(resultPath, 'cPDistMatrix.mat'), 'cPDistMatrix');
save(fullfile(resultPath, 'cPMapsMatrix.mat'), 'cPMapsMatrix');

end
