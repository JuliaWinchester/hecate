function success = delete_recursively(d)
% DELETE_RECURSIVELY - Delete all files in directory and subdirectories

l = arrayfun(@(x) x.name, dir(d), 'UniformOutput', 0);
l = l(3:end);
j = arrayfun(@(x) fullfile(d, x), l, 'UniformOutput', 0);
sub_dirs = j(cellfun(@(x) isdir(x), j));
files = j(cellfun(@(x) ~isdir(x), j));
delete(files);
for s = sub_dirs
	delete_recursively(s);
end
