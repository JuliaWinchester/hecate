function flatSamples = cluster_flatten(cfgPath)
% CLUSTER_FLATTEN - Submit on_grid/flatten jobs to cluster

[meshNames, meshPaths, flatPath] = load_cfg(cfgPath, 'data.meshNames', ...
    'data.meshPaths', 'path.flat');

disp('++++++++++++++++++++++++++++++++++++++++++++++++++');
disp('Submitting jobs for sampling mesh files');

flatSamples = cell(1, length(meshNames));
for k = 1:length(meshNames)
    job_id = k;
    
    samplePath = fullfile(flatPath, '/samples/', [meshNames{k} '.mat']);

    if exist(samplePath, 'file') == 2
        continue;
    end

    flatSamples{k} = samplePath;
    scriptPath = fullfile(flatPath, '/cluster/script/', ... 
        ['script_' num2str(job_id)]);
    
    fid = fopen(scriptPath, 'w');
    fprintf(fid, '#!/bin/bash\n');
    fprintf(fid, '#$ -S /bin/bash\n');
    script_text = ['matlab -nodesktop -nodisplay -nojvm -nosplash -r ' ...
        ' "cd ' fullfile(pwd, '/cpd/on_grid/') '; ' ...
        'path(genpath(''../../util/''), path); ' ...
        'flatten_ongrid ' ...
        meshPaths{k} ' ' ...
        samplePath '; exit; "'];
    % system(script_text); %% grid fails on certain tasks
    fprintf(fid, '%s',script_text);
    fclose(fid);
    
    %%% qsub
    jobname = ['fjob_' num2str(job_id)];
    err = fullfile(flatPath, '/cluster/error/', ['e_job_' num2str(job_id)]);
    out = fullfile(flatPath, '/cluster/out/', ['o_job_' num2str(job_id)]);
    tosub = ['!qsub -N ' jobname ' -o ' out ' -e ' err ' ' scriptPath];
    eval(tosub);  
end

end
