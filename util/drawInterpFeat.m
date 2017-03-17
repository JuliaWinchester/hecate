function h = drawInterpFeat(G,feature,order_list)

	figure;
	G.draw();
	hold on;
	color_list = {'g', 'r', 'b', 'y', 'm', 'c', 'w', 'k'};
	for i = 1:length(order_list)
		pt = feature(:, order_list(i));
		scatter3(pt(1,:), pt(2,:), pt(3,:),color_list{i},'filled');
	end

end