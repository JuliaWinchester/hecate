# spark_on_sge
This repository contains a set of scripts to launch a standalone Apache Spark environment on the [Duke Mathematics Sun Grid Engine Cluster](https://math.duke.edu/sge-cluster-documentation), to run Spark application tasks in that environment, and to clean up and shut down the environment. These scripts were written by Julie Winchester (julia.winchester@duke.edu), and were in part inspired by by 4Quant's [spark_sge](https://github.com/4Quant/sge_spark) repository.

## Usage
First, check (and if needed, modify) `conf/sge.sh` and `conf/spark-env.sh`. These files contain environmental variables for SGE and Spark respectively. In `sge.sh`, `NUM_QSUB_JOBS` determines the number of Spark workers, since each individual worker is submitted as a qsub job to allow the SGE cluster to manage resources efficiently. `LOG_DIR` determines where Spark worker output and Spark master webUI should be logged to. Variables in `spark-env.sh` are standard Spark parameters.

Next, run `spark-run.sh` with the Spark application file to be submitted as the first command line argument, followed by any subsequent arguments for that application. For instance, here is how to launch the "Run a Python application on a Spark standalone cluster" example from the Spark [application submission guide](http://spark.apache.org/docs/latest/submitting-applications.html): 

```bash
spark-run.sh ~/spark/examples/src/main/python/pi.py 1000
```

After `spark-run.sh` completes, the application task should be complete and the Spark environment should be cleaned up and shut down. The log directory should now contain the combined out/error streams of Spark workers as text files and a local html mirror of the main Spark master webUI page.

