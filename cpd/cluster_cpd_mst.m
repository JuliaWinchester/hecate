function cluster_cpd_mst(cfgPath)
% CLUSTER_CPD_MST - Launch Spark environment/application for CPD MST step
	cd 'util/spark_on_sge-0.2/';
	script_call = ['spark_run.sh ../../cpd/cpd_mst/cpd_mst.py ' cfgPath];
	system(script_call);

end
