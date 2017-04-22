function cluster_cpd_mst(cfgPath)
% CLUSTER_CPD_MST - Launch Spark environment/application for CPD MST step
	eval(['../util/spark_on_sge-0.2/spark_run.sh ./cpd_mst/cpd_mst.py ' cfgPath]);
end