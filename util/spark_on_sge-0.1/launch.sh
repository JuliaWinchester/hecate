#!/bin/bash

# Launches a set of Spark master and worker processes on Sun Grid Engine (SGE)
# cluster architecture. The Spark standalone cluster manager is used to
# coordinate driver and worker nodes. Worker processes are launched manually as 
# SGE qsub jobs, allowing the cluster to efficiently manage resources. This
# script should generally not be run on its own as it does not include any
# ability to exit launched spark processes. Instead, the script spark_run.sh
# should be run, since it automates spark environment launch, spark application
# submission, and spark process/qsub job clean-up. Nonetheless, after launch.sh
# is run it is necessary to run clean_up.sh or else Spark processes will not 
# close. As noted, spark_run.sh automates this. 

function check_free_port () {
	if [[ $(netstat -lnt | awk '$6 == "LISTEN" && $4 ~ ".{$MASTER_PORT}"') ]]; then
		SPARK_MASTER_PORT = "shuf -i 7001-7099 -n 1"
		check_free_port
	else
		return
	fi
}

. "conf/sge.sh"
. "conf/spark-env.sh"

# Delete logs from previous run
rm -rf ./sge/log/*.txt
rm -rf ./sge/log/webui

SPARK_MASTER_HOST=$(hostname -i)
SPARK_MASTER_PORT=$(shuf -i 7001-7099 -n 1)
check_free_port

$SPARK_HOME/sbin/spark-daemon.sh start org.apache.spark.deploy.master.Master 1 \
	--host $SPARK_MASTER_HOST --port $SPARK_MASTER_PORT

for i in $(seq 1 $NUM_QSUB_JOBS)
do
	qsub -v SPARK_HOME=/home/collabor/jwinch/spark/ \
		-v SPARK_MASTER_HOST=$SPARK_MASTER_HOST \
		-v SPARK_MASTER_PORT=$SPARK_MASTER_PORT \
		-v NUM_CORES=$SPARK_WORKER_CORES -v MEM=$SPARK_WORKER_MEMORY \
		-v LOG_DIR = $LOG_DIR \
		./sge/spark_worker.sge
done


