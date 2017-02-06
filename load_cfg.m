function varargout = load_cfg(cfgPath, varargin)
% LOAD_CFG - Loads requested variables from cfg in cfgPath

cfg = load(cfgPath);
for i = 1:length(varargin)
	varargout{i} = cfg.(varargin{1});
end

end
