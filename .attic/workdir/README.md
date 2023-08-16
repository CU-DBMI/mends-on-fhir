# Implementation
This directory will be mounted into the whistle docker container as /whistle. The subdirectories are as follows:
* `input-examples/*` are example input JSON files to use for demonstration purposes. Some or all of these directories are git submodules.
* `whistle-output` contains the output of a whistle run on a set of input files. All existing files (but not sub folders) will be deleted with each run before creating the new output files.
  * As an option, the output can be placed in nested datetime stamped folders to be able to keep parallel outputs when needed.
* 
* `mapping-functions` is the directory that will contain the mapping files that were used by the whistle engine for generating the output. The files in this directory will all be deleted and repopulated by the CLI with the mapping files for the current run
  * As an option, datetime stampped sub folders can be used to keep the mapping files along with the datetime stamped output files.
* `mapping-concept-maps` as above but for the ConceptMap files.


# TODO

* next the above top directories under datetime stamped subfolders instead of as described above. In other words, each datetime sub folder will contain the mapping files and outputs for a whistle run. The input files are specified from their original sources.
* 
