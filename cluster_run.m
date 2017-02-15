function cluster_run(func, funcArg, codePath, jobPath, varargin)
% CLUSTER_RUN - Runs SGE cluster jobs

touch(jobPath);

optArgs = {'crJob', 0, '', 0, ''};
optArgs(1:length(varargin)) = varargin;
[jobName, sync, holdID, email, emailAddress] = optArgs{:};

PBS = '#PBS -l nodes=1:ppn=1,walltime=3:00:00\n#PBS -m abe\n';
command = 'matlab -nodesktop -nodisplay -nosplash -r ';
matlab_call = [ ...
	'\"cd ''' codePath '''; ' ...
	'path(pathdef); ' ...
	'addpath(path,genpath(''' codePath ''')); ' ... 
	func '(' funcArg '); exit;\"'];

errPath = fullfile(jobPath, [func '_err']);
outPath = fullfile(jobPath, [func '_out']);
shPath = fullfile(jobPath, [func '.sh']);

txt = [PBS command matlab_call];
fid = fopen(shPath, 'w');
fprintf(fid, txt);
fclose(fid);

qsub = '!qsub ';
etcArg = ['-N ' jobName ' -e ' errPath ' -o ' outPath ' ' shPath];
if sync
	syncArg = '-sync y ';
else
	syncArg = '';
end
if length(holdID) > 0
	holdArg = ['-hold_jid ' holdID ' '];
else
	holdArg = '';
end
if email
	emailArg = ['-m e -M ' emailAddress ' '];
else
	emailArg = '';
end

qsub_call = [qsub syncArg holdArg emailArg etcArg];
disp(['Calling ' qsub_call]);
eval(qsub_call);
	
end
	
