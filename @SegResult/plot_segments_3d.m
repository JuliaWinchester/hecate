function plot_segments_3d(SegResult, n, filePath)
% PLOT_SEGMENTS_3D - Plots and opt. saves figure of segments for n random meshes
% Adapted in part from original util/ViewBundleFunc.m

	% sample_path = options.sample_path;
	% DisplayLayout = options.DisplayLayout;
	% GroupSize = length(Names);
	% mesh_list = cell(size(Names));
	% R = options.R;
	% linkCamera = getoptions(options,'linkCamera','on');
	% DisplayOrient = getoptions(options,'DisplayOrient','Horizontal');

	% switch DisplayOrient
	%     case 'Vertical'
	%         DisplayOrder = reshape(1:DisplayLayout(1)*DisplayLayout(2), DisplayLayout(2), DisplayLayout(1));
	%         DisplayOrder = DisplayOrder';
	%         DisplayOrder = DisplayOrder(:);
	%     case 'Horizontal'
	%         DisplayOrder = 1:DisplayLayout(1)*DisplayLayout(2);
	% end

	% for i=1:GroupSize
	%     GM = load([sample_path Names{i} '.mat']);
	%     GM = GM.G;
	%     % align every tooth to the first one on the list
	%     if (i==1)
	%         mesh_list{i} = GM;
	%     else
	%         GM.V = R{1,i}*GM.V;
	%         mesh_list{i} = GM;
	%     end
	% end

	% if (~isempty(findobj('Tag','BundleFunc')))
	%     camUpVector = get(gca, 'CameraUpVector');
	%     camPosition = get(gca, 'CameraPosition');
	%     camTarget = get(gca, 'CameraTarget');
	%     camViewAngle = get(gca, 'CameraViewAngle');
	%     figurePosition = get(gcf, 'Position');
	% else
	%     figurePosition = [10, 10, 800, 800];
	% end

	figurePosition = [10, 10, 800, 800];
	figure('Unit', 'pixel', 'Position', figurePosition);
	set(gcf, 'ToolBar', 'none');
	h = zeros(size(n));
	rng('shuffle');
	hIdx = randi(length(SegResult.mesh), n, 1);

	nRow = floor(sqrt(n));
	nCol = ceil(n/nrow);

	% BlockShift = zeros(1,GroupSize);
	% for j=1:GroupSize
	%     BlockShift(j) = mesh_list{j}.nV;
	% end
	% BlockShift = cumsum(BlockShift);
	% BlockShift = [0 BlockShift];

	for i=1:n
		m = SegResult.mesh{hIdx(i)};
	    color_data = m.segmentIdx;
	    h(i) = subplot(nRow, nCol, i);
	    m.draw(struct('FaceColor', 'interp', 'FaceVertexCData', color_data, 'CDataMapping','scaled', 'EdgeColor', 'none', 'FaceAlpha',1,'AmbientStrength',0.3,'SpecularStrength',0.0));
	    hold on;
	    colormap jet(256);
	    camlight('headlight');
	    camlight(180,0);
	    title(m.Aux.name);
	end

	% if strcmpi(linkCamera, 'on')
	%     Link = linkprop(h, {'CameraUpVector', 'CameraPosition', 'CameraTarget', 'CameraViewAngle'});
	%     setappdata(gcf, 'StoreTheLink', Link);
	% end

	% if (exist('camUpVector', 'var'))
	%     set(gca, 'CameraUpVector', camUpVector);
	%     set(gca, 'CameraPosition', camPosition);
	%     set(gca, 'CameraTarget', camTarget);
	%     set(gca, 'CameraViewAngle', camViewAngle);
	%     set(gcf, 'Tag', 'BundleFunc');
	% end

end