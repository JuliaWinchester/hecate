hecate
======

Consistent segmentation of biological surfaces by spectral clustering from a hypoelliptic diffusion map. This method was developed by Tingran Gao (trgao10@math.duke.edu) (cites) and this software incorporates code from repositories [cPdist](https://github.com/trgao10/cPdist) and [HDM](https://github.com/trgao10/HDM) written by Tingran Gao. Julie Winchester (julia.m.winchester@gmail.com) is the author and maintainer for hecate. 

This software reads 3D surface mesh files in .off format and leverages an SGE cluster computing environment to calculate continuous procrustes distances between surfaces, a hypoelliptic diffusion map generated from the distance matrix, and biological surface segments created via spectral clustering from the diffusion map. Output results include .off-format surface fiiles representing whole original meshes and mesh section segments, data tables detailing simple quantitative characteristics of segmented meshes, and plots representing mesh segments and mesh segment data.

Using hecate
------------

Users should first edit the `user_settings.m` file. Descriptions of `user_settings.m` fields can be found below. After settings have been customized, the software can be run by opening `MATLAB` in a cluster computing environment and running the script `start_hecate.m`. All further analysis is automated. A series of cluster jobs will be created which can be tracked using the `qstat` command. The primary program control job is named "hecate" and the analysis is complete when this job finishes. See below for a description of output result files.

User settings
-------------

Below are descriptions of the fields in user_settings.m that are most likely to be modified. 

`meshDir`: Path to a single directory containing all surface mesh files in .off format. 

`outputDir`: Path to a single directory in which results will be placed. 

`email`: An optional e-mail address, if the user wishes to be contacted by the cluster at completion of major analysis steps. All analysis is complete when the job "hecate" is finished. 

`alignTeeth`: 0 or 1, whether or not teeth should be rotationally aligned (using the continuous procrustes distance matrix) when exporting meshes and segments. The choice of this parameter will not affect analysis results, only exported files. 

`dirCollate`: 0 or 1, whether or not exported mesh segment files (`mesh1_seg1.off`) should be collated into mesh directories (`mesh1/mesh1_seg1.off`). If 0, all mesh segment files are placed in a single directory. 

`meshDisplayNumber`: A representative MATLAB figure showing segments from a random collection of meshes is produced, this parameter determines the number of meshes in this figure. 

Diffusion map parameters: The diffusion map is generated based on four possible parameters. Effects of these on generated segments needs to be tested further. The `BNN` parameter should be lower than the number of surface meshes used. 

Consistent spectral clustering parameters: `segmentNum` controls the maximum number of segments to be generated. The effect of the parameter `eigCols` on generated segments needs to be tested further. 

Analysis control: Putting 0 or 1 values in these steps allows users to control which of the major analysis steps are run. This can be helpful, for example, when wanting to run only the last two major analysis steps as the first three steps are by far the most time consuming.

Results
-------

Below is a list of output result directories and files with short descriptions. 

`mesh/`: This directory contains original meshes in .off format. 

`segment/`: This directory contains mesh section segments in .off format.

`freq_dist.eps`: Frequency distribution plot showing numbers of segments per mesh across sample. 

`mesh.csv`: Data table listing mesh and segment data per mesh. 

`result.mat`: MATLAB file containing analysis result object. This result object contains all mesh and segment surfaces and calculated secondary data, and can be used to extract further information from the analysis than is provided in these result files. 

`seg_group.off`: A surface file containing all sample segments laid out by mesh. 

`segment.csv`: Data table listing segment data per mesh segment. This data is distinct from that in `mesh.csv`.

`segment.fig`: MATLAB figure showing a representative collection of segments from an number of meshes defined in `user_settings.m`. These surfaces are visualized in 3D and segments are colored for ease of comparison. 
