#!/bin/bash

# Contains environmental variables for running Spark. Since spark_on_sge uses 
# standalone Spark cluster management, standalone deployment environment
# variables can be set here. Variables currently set include: 
#	- SPARK_HOME, location of Spark install
#	- SPARK_DRIVER_MEMORY, the amount of memory allocated to driver
#	- SPARK_WORKER_CORES, the number of cores used per worker process
#	- SPARK_WORKER_MEMORY, amont of memory allocated to each worker process

export SPARK_HOME="/home/collabor/jwinch/spark/"
export SPARK_DRIVER_MEMORY="40G"
export SPARK_WORKER_CORES=1
export SPARK_WORKER_MEMORY=2G

