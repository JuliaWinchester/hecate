function success = delete_recursively(d)
% DELETE_RECURSIVELY - Delete all files in directory and subdirectories

l = arrayfun(@(x) x.name, dir(d), 'UniformOutput', 0);
l = l(3:end);
j = cellfun(@(x) fullfile(d, x), l, 'UniformOutput', 0);
sub_dirs = j(cellfun(@(x) isdir(x), j));
files = j(cellfun(@(x) ~isdir(x), j));

for i = 1:length(files)
	delete(files{i});
end

for s = 1:length(sub_dirs)
	delete_recursively(sub_dirs{s});
end

end
