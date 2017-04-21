#!/bin/bash

# Submits an application task to the Spark environment created by launch.sh.
# The application python script or jar should be supplied as a script argument.
# If this script is run by itself, SPARK_MASTER_HOST and SPARK_MASTER_PORT must
# be specified as environment variables. Typically, spark_run.sh should be run 
# instead since it automates environment launch, application submission, and
# clean-up.  

. "conf/spark-env.sh"

$SPARK_HOME/bin/spark-submit \
	--master spark://$SPARK_MASTER_HOST:$SPARK_MASTER_PORT \
	--deploy-mode client \
	--driver-memory $SPARK_DRIVER_MEMORY \
	"$@"