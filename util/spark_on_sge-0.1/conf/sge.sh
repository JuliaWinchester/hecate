#!/bin/bash

# Contains environmental variables for running SGE Qsub jobs. Currently only
# one variable can be set:
#	- NUM_WORKERS, The number of spark worker processes to start via qsub

# Other possible variables that may be included in the future could include max
# uptime or required memory amounts for qsub jobs running spark workers. 

export NUM_QSUB_JOBS=100
export LOG_DIR="./sge/log/"