function cluster_cpd_mst(cfgPath)
% CLUSTER_CPD_MST - Launch Spark environment/application for CPD MST step
	eval('cd ../util/spark_on_sge-0.2/')
	eval(['spark_run.sh ../../cpd/cpd_mst/cpd_mst.py ' cfgPath]);
end