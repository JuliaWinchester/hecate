function varargout = load_cfg(cfgPath, varargin)
% LOAD_CFG - Loads requested variables from cfg in cfgPath

load(cfgPath);
for i = 1:length(varargin)
	fields = strsplit(varargin, '.');
	res = cfg;
	for j = 1:length(fields)
		res = res.(fields{j});
	end
	varargout{i} = res;
end

end
