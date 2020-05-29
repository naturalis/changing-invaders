# changing-invaders
Scripts and config files for assembly and SNP design of genomics of Polynesian rats

The source tree is:
```
├───data - data (on Docker image) and yml file to reflect the data for first steps of the flowchart
├───local-data - data and yml file to reflect the data for first steps of the flowchart to use in the pipeline
├───doc
│   ├───flowchart - flowchart images to show in /script/* folders
│   ├───stepsToSNPs - explaination of SNPs in English language
│   └───translations - translation of 2 articles of AAE Van Der Geer in the Dutch language
├───lib
│   └───My
│       └───ChangingInvaders - perl modules for first ~2 scripts
└───script - actual scripts (this and every subdirectory contains a flowchart to represent what part of the flow one is looking at)
    ├───ancestorPopulationStructure
    ├───blastSNPs
    ├───consensusGenome
    ├───filteringChoice
    ├───geneOntology
    ├───makeDatabases
    │   ├───3_samples
    │   ├───8_samples
    │   └───row_based
    └───readsToVariants
```
Please not that different runs of the same sample should be located in different subdirectories under local-data. If this isn't done and the naming sheme is used that here is documented and more than 1 run belongs to one sample, your data will be incorrect because of the `--dont_overwrite` policy enforced in `fastp.pl`. fastq-files should be named samplename_*adapter used for the run*\_L002\_R*1 or 2 depending on pair*\_*run name*.fastq.gz other naming shemes *might* work out as well but this is recommend. Also create a YAML file (`files.yml`) on the same folder as the data:
```bash
---
reference:
  Rnor_6.0: /var/data/data/path to reference(fasta.gz)
  Rnor_6.0-filtered: /var/data/data/path to filtered reference(fasta.gz)
sample:
  samplename(for every sample):
    run:
      run name(for every run):
        file:
          fastp:
            - /var/data/data/filename_first of pair.fastp.fastq.gz
            - /var/data/data/C0910_41662_TTCCTCCTTTGCTTGC_L001_R2_001_H5YKNDRXX.filt.fastp.fastq.gz (filename 2nd of pair)
          raw:
            - /var/data/data/filename_first of pair.fastq.gz
            - /var/data/data/filename_second of pair.fastq.gz
```
and this repeated for every file you have. Note the relativeness of the paths since /var/data/data is where your data is mounted in docker, so every path must start that way. (or you have to mount somewhere different of course)
For convenience there is a script included to provide mouse data that can directly be used with the fastq pipeline. The script is called `script/mouse2pipeline.sh`. This file will create a directory 'mouse' which could be used as the local-data directory

The docker-image might be invoked using
```bash
docker build -t changing-invaders:v1.0 .
# local-data could of course be changed to every folder that contains your data and the files.yml file
docker run -v $PWD/local-data:/var/data/data -ti changing-invaders:v1.0 ./fastqTo100SNPs.sh
```
optionally one can directly see the results of ggplot (without writing to a file) using this method: first run on the host:
```
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
```
and then call docker with these arguments:
```bash
-v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH
```
added after $PWD/local-data:/var/data/data
and within the container execute: `export DISPLAY=:0`
Of course this will not work on a Windows system or a system that has no X server available.

Many scripts take some time to run(especially in scripts/readsToVariants folder). Because of this the slurm system is used.
This is a system that manages jobs on a server. Therefore a lot of (bash)scripts in this repository make use of sbatch and the following structure:
```bash
#!/bin/bash
# what the script does
code to parse arguments of set them on default values
[ $# -gt 0 ]&&variable1=$1||variable1=standard_argument
code that checks whether file arguments are available
if test $(that is the case);then
 sbatch <<< '#!/bin/bash
  # read code
  program_a "'"$variable1"'"
'
fi
```
Please note that sbatch is the program where jobs are made known on the server. The program the job comprend is on the next lines.
Because there is worked with '(single quote) arguments that are given are within "'" (double quote so most variables could contain spaces)

For this repo with a lot of things still in Dutch I refer to this commit: https://github.com/naturalis/changing-invaders/commit/184a23c18492c1197a6f8936b0b42a7750dde9e4
For all scripts before cleanup(and translation) I refer to: https://github.com/naturalis/changing-invaders/tree/922c543dcc55c43b1ed627e0396ae57dc107ad10
