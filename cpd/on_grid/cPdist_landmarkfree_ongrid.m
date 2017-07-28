function cPdist_landmarkfree_ongrid(G1,G2,rslt_mat,TAXAind1,TAXAind2, featureType, numFeatureMatch)

GM = load(G1);
GM = GM.G;
GN = load(G2);
GN = GN.G;

load(rslt_mat);

options.FeatureType = featureType;
options.NumDensityPnts = 100;
options.AngleIncrement = 0.01;
options.NumFeatureMatch = str2double(numFeatureMatch);
options.GaussMinMatch = 'off';
options.ProgressBar = 'off';

disp(['Comparing ' GM.Aux.name ' vs ' GN.Aux.name '...']);

rslt = GM.ComputeContinuousProcrustes(GN,options);

cPrslt{str2double(TAXAind1),str2double(TAXAind2)} = rslt;
save(rslt_mat,'cPrslt');

disp(['cPdist(' GM.Aux.name ', ' GN.Aux.name ') = ' num2str(rslt.cPdist) '.']);

end

