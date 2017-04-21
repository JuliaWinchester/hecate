#!/bin/bash

# Automates the running of scripts launch.sh, app.sh, and clean_up.sh. The Spark
# application python script or jar should be specified as an argument.  

. "conf/sge.sh"
. "conf/spark-env.sh"

. "launch.sh"

. "app.sh" "$@"

. "clean_up.sh"

