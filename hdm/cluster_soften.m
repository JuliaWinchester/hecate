function resultPath = cluster_soften(cfgPath)
% CLUSTER_SOFTEN - Submit soften_ongrid jobs to cluster

[fiberEps, flatSamples, cpdMstPath, softenPath, resultPath] = ...
    load_cfg(cfgPath, 'param.fiberEps', 'data.flatSamples', 'path.cpdMST', ...
        'path.soften', 'path.softenJobMats');

errPath = fullfile(softenPath, '/cluster/error/');
outPath = fullfile(softenPath, '/cluster/out/');
scriptPath = fullfile(softenPath, '/cluster/script/');

disp('++++++++++++++++++++++++++++++++++++++++++++++++++');
disp(['Submitting jobs for comparing sample files...' ]);

cnt = 0;
jobID = 0;
for k1=1:length(flatSamples)
    for k2=1:length(flatSamples)
        if mod(cnt,chunkSize)==0
            if jobID > 0 %%% not the first time
                %%% close the script file (except the last one, see below)
                fprintf(fid, '%s ', 'exit; "\n');
                fclose(fid);
                
                %%% qsub
                jobName = ['Sjob_' num2str(jobID)];
                err = fullfile(errPath, ['e_job_' num2str(jobID)]);
                out = fullfile(outPath, ['o_job_' num2str(jobID)]);
                tosub = ['!qsub -N ' jobName ' -o ' out ' -e ' err ' ' ...
                         scriptName];
                eval(tosub);
            end
            
            jobID = jobID+1;
            scriptName = fullfile(scriptPath, ['script_' num2str(jobID)]);
            
            %%% open the next (first?) script file
            fid = fopen(scriptName,'w');
            fprintf(fid, '#!/bin/bash\n');
            fprintf(fid, '#$ -S /bin/bash\n');
            scriptText = ['matlab -nodesktop -nodisplay -nojvm -nosplash -r '...
                '" cd ' fullfile(pwd, '/hdm/on_grid/') '; ' ...
                'path(genpath(''../../util/''), path); ' ...
                'options.TextureCoords1Path = ''' fullfile(cpdMstPath, '/tc1/') ''';' ...
                'options.TextureCoords2Path = ''' fullfile(cpdMstPath, '/tc2/') ''';' ...
                'options.fibrEps = ''' num2str(fiberEps) ''';'];
            fprintf(fid, '%s ',scriptText);
            
            %%% create new matrix
            if ~exist(fullfile(resultPath, ['soften_mat_' num2str(jobID) '.mat']),'file')
                cPSoftMapsMatrix = cell(length(flatSamples));
                save(fullfile(resultPath, ['soften_mat_' num2str(jobID)]), 'cPSoftMapsMatrix');
            end
        end
        filename1 = flatSamples{k1};
        filename2 = flatSamples{k2};
        
        scriptText = [' soften_ongrid(''' ...
            filename1 ''', ''' ...
            filename2  ''', ''' ...
            fullfile(resultPath, ['soften_mat_' num2str(jobID)]) ''', ' ...
            num2str(k1) ', ' ...
            num2str(k2) ', ' ...
            'options);'];
        fprintf(fid, '%s ',scriptText);
        
        cnt = cnt+1;
    end
    
end

% if mod(cnt,chunkSize)~=0
%%% close the last script file
fprintf(fid, '%s ', 'exit; "\n');
fclose(fid);
%%% qsub last script file
jobName = ['Sjob_' num2str(jobID)];
err = fullfile(errPath, ['e_job_' num2str(jobID)]);
out = fullfile(outPath, ['o_job_' num2str(jobID)]);
tosub = ['!qsub -N ' jobName ' -o ' out ' -e ' err ' ' scriptName ];
eval(tosub);
% end

