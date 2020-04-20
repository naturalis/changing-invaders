#!/bin/bash
# changing invaders
#SBATCH --job-name=ci-merge
#SBATCH --output=ci-merge.out

DIR=/home/rutger.vos/fileserver/projects/B19005-525/Samples/
SAMPLES=$(ls $DIR)
for SAMPLE in $SAMPLES; do
  cd $DIR/$SAMPLE
    export SAMPLE
    if [[ ! -e ${SAMBLE}.bam ]]; then
      perl -e 'print printf("\@RG\tID:NA\tSM:%s\tPL:ILLUMINA\tPI:NA", $ENV{SAMPLE})' > rg.txt
      samtools merge -rh rg.txt -l 9 --threads 16 ${SAMPLE}.bam *.bam
    fi
  cd -
done
