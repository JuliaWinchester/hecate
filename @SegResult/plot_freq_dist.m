function plot_freq_dist(SegResult, filePath)
% PLOT_FREQ_DIST - Plots and opt. saves freq dist of segment number per mesh

	h = histogram(SegResult.data.segmentN, [1:16]);
	xlabel('Segment ID');
	ylabel('Number of segments');
	title('Frequency distribution of number of segments per mesh');
	saveas(gcf, filePath);

end