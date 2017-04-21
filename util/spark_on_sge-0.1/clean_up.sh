#!/bin/bash

# Cleans up after launch.sh. Stops Spark master process and uses qdel to kill
# qsub jobs running Spark worker processes. This script must be run at some
# point after launch.sh. Typically, the script spark_run.sh should be used, as
# it automates the running of launch.sh, a Spark application task, and this 
# script. 

. "conf/sge.sh"
. "conf/spark-env.sh"

wget -m -P $LOG_DIR/webui/ "localhost:8080"

$SPARK_HOME/sbin/stop-master.sh

qdel sp_wrkr

