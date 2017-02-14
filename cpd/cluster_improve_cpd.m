function [resultPath, chunkSize] = cluster_improve_cpd(cfgPath)
% CLUSTER_IMPROVE_CPD - Improve continuous procrustes distance with MST/Viterbi

[imprType, featureFix, chunkSize, flatSamples, flatPath, cpdPath, cpdiPath, ...
    resultPath] = load_cfg(cfgPath, 'param.imprType', 'param.featureFix', ...
    'param.chunkSize', 'data.flatSamples', 'path.flat', 'path.cpd', ...
    'path.cpdImprove', 'path.cpdImproveJobMats'); 

errPath    = fullfile(cpdiPath, '/cluster/error/');
outPath    = fullfile(cpdiPath, '/cluster/out/');
scriptPath = fullfile(cpdiPath, '/cluster/script/');
cPLASTPath = '';

disp('++++++++++++++++++++++++++++++++++++++++++++++++++');
disp(['Submitting jobs for comparing flatten sample files in...' ]);

cnt = 0;
jobID = 0;
for k1=1:length(flatSamples)
    for k2=1:length(flatSamples)
        if mod(cnt,chunkSize) == 0
            if jobID > 0 %%% not the first time
                %%% close the script file (except the last one, see below)
                fprintf(fid, '%s ', 'exit; "\n');
                fclose(fid);
                
                %%% qsub
                jobName = ['ijob_' num2str(jobID)];
                err = fullfile(errPath, ['e_job_' num2str(jobID)]); 
                out = fullfile(outPath, ['o_job_' num2str(jobID)]);
                tosub = ['!qsub -N ' jobName ' -o ' out ' -e ' err ' ' ...
                         scriptName ];
                eval(tosub);
            end
            
            jobID = jobID+1;
            scriptName = fullfile(scriptPath, ['script_' num2str(jobID)]);
            
            %%% open the next (first?) script file
            fid = fopen(scriptName, 'w');
            fprintf(fid, '#!/bin/bash\n');
            fprintf(fid, '#$ -S /bin/bash\n');
            scriptText = ['matlab -nodesktop -nodisplay -nojvm -nosplash -r '...
                '" cd ' fullfile(pwd, '/cpd/on_grid/') '; ' ...
                'path(genpath(''../../util/''), path); ' ...
                'load(''' fullfile(cpdPath, 'cpDistMatrix.mat') ''');' ...
                'load(''' fullfile(cpdPath, 'cpMapsMatrix.mat') ''');' ...
                'options.TextureCoords1Path = ''' fullfile(cpdPath, '/texture_coords_1/') ''';' ...
                'options.TextureCoords2Path = ''' fullfile(cpdPath, '/texture_coords_2/') ''';' ...
                'options.ChunkSize = ' num2str(chunkSize) ';' ...
                'options.cPLASTPath = ''' cPLASTPath ''';'];
            fprintf(fid, '%s ',scriptText);
            
            %%% create new matrix
            if ~exist(fullfile(resultPath, ['rslt_mat_' num2str(jobID) '.mat']),'file')
                Imprrslt = cell(flatSamples);
                save(fullfile(resultPath, ['rslt_mat_' num2str(jobID)]), 'Imprrslt');
            end
        end
        filename1 = flatSamples{k1};
        filename2 = flatSamples{k2};
        
        scriptText = [' Imprdist_landmarkfree_ongrid(''' ...
            filename1 ''', ''' ...
            filename2  ''', ''' ...
            fullfile(resultPath, ['rslt_mat_' num2str(jobID)]) ''', ' ...
            num2str(k1) ', ' ...
            num2str(k2) ', ''' ...
            imprType ''', ''' ...
            featureFix ''', ' ...
            'cpDist, cpMaps, options);'];
        fprintf(fid, '%s ',scriptText);
        
        cnt = cnt+1;
    end
    
end

% if mod(cnt,chunkSize)~=0
%%% close the last script file
fprintf(fid, '%s ', 'exit; "\n');
fclose(fid);
%%% qsub last script file
jobName = ['ijob_' num2str(jobID)];
err = fullfile(errPath, ['e_job_' num2str(jobID)]);
out = fullfile(outPath, ['o_job_' num2str(jobID)]);
tosub = ['!qsub -N ' jobName ' -o ' out ' -e ' err ' ' scriptName ];
eval(tosub);

end

