# changing-invaders
Scripts and config files for assembly and SNP design of genomics of Polynesian rats

The source tree is:
```
├───data - data and yml file to reflect the data for first steps of the flowchart
├───doc
│   ├───flowchart - flowchart images to show in /script/\* folders
│   ├───stepsToSNPs - explaination of SNPs in English language
│   └───translations - translation of 2 articles of AAE Van Der Geer in the Dutch language
├───lib
│   └───My
│       └───ChangingInvaders - perl modules for first ~2 scripts
└───script - actual scripts
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
Because there is worked with '(single quote) arguments that are given are within "'" (double quote so most variabeles could contain spaces)

For this repo with a lot of things still in Dutch I refer to this commit: https://github.com/naturalis/changing-invaders/commit/184a23c18492c1197a6f8936b0b42a7750dde9e4
For all scripts before cleanup(and translation) I refer to: https://github.com/naturalis/changing-invaders/tree/922c543dcc55c43b1ed627e0396ae57dc107ad10
