function [resultPath, chunkSize] = cluster_improve_cpd(imprType, featureFix, flatSamples, outputDir, cpdResultPath, chunkSize)
% CLUSTER_IMPROVE_CPD - Improve continuous procrustes distance with MST/Viterbi

errPath    = fullfile(outputDir, 'etc/cpd_improve/cluster/error/');
outPath    = fullfile(outputDir, 'etc/cpd_improve/cluster/out/');
scriptPath = fullfile(outputDir, 'etc/cpd_improve/cluster/script/');
resultPath = fullfile(outputDir, 'etc/cpd_improve/job_mats/');

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
                jobName = ['cpdimprjob_' num2str(jobID)];
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
                '" cd ' fullfile(pwd, 'on_grid') '; ' ...
                'path(genpath(''../../util/''), path); ' ...
                'load(''' fullfile(cpdResultPath, 'cPDistMatrix.mat') ''');' ...
                'load(''' fullfile(cpdResultPath, 'cPMapsMatrix.mat') ''');' ...
                'options.TextureCoords1Path = ''' fullfile(cpdResultPath, '/texture_coords_1/') ''';' ...
                'options.TextureCoords2Path = ''' fullfile(cpdResultPath, '/texture_coords_2/') ''';' ...
                'taxa_code = load(''' TaxaCode_path ''');' ... % address this first!!!
                'options.TaxaCode = taxa_code.taxa_code;' ... % !!!
                'options.ChunkSize = ' num2str(chunkSize) ';' ...
                'options.cPLASTPath = ''' cPLASTPath ''';'];
            fprintf(fid, '%s ',scriptText);
            
            %%% create new matrix
            if ~exist([resultPath 'rslt_mat_' num2str(jobID) '.mat'],'file')
                Imprrslt = cell(GroupSize,GroupSize);
                save([rslts_path 'rslt_mat_' num2str(jobID)], 'Imprrslt');
            end
        end
        filename1 = [samples_path taxa_code{k1} '.mat'];
        filename2 = [samples_path taxa_code{k2} '.mat'];
        
        scriptText = [' Imprdist_landmarkfree_ongrid(''' ...
            filename1 ''', ''' ...
            filename2  ''', ''' ...
            [rslts_path 'rslt_mat_' num2str(jobID)] ''', ' ...
            num2str(k1) ', ' ...
            num2str(k2) ', ''' ...
            ImprType ''', ''' ...
            FeatureFix ''', ' ...
            'cPDistMatrix, cPMapsMatrix, options);'];
        fprintf(fid, '%s ',scriptText);
        
        cnt = cnt+1;
    end
    
end

% if mod(cnt,chunkSize)~=0
%%% close the last script file
fprintf(fid, '%s ', 'exit; "\n');
fclose(fid);
%%% qsub last script file
jobname = ['cpdimprjob_' num2str(jobID)];
serr = [errors_path 'e_job_' num2str(jobID)];
sout = [outputs_path 'o_job_' num2str(jobID)];
tosub = ['!qsub -N ' jobname ' -o ' sout ' -e ' serr ' ' scriptName ];
eval(tosub);
% end

