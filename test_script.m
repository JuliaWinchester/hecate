center = @(X) X-repmat(mean(X,2),1,size(X,2));
scale  = @(X) norm(center(X),'fro') ;

a = Mesh('off', meshPath);
%a.V = center(a.V) / scale(a.V);
a.remove_zero_area_faces();
a.remove_unref_verts();
a.V = center(a.V) / scale(a.V);

a.Write('~/test.off','off',struct);
flatten_ongrid('~/test.off', '~/test.mat');

