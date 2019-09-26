#!/bin/bash

#SBATCH --job-name=ci-merge
#SBATCH --output=ci-merge.out

DIR=/home/rutger.vos/fileserver/projects/B19005-525/Samples/
SAMPLES=$(ls $DIR)
for SAMPLE in $SAMPLES; do
  cd $DIR/$SAMPLE
    echo "@RG\tID:NA\tSM:${SAMPLE}\tPL:ILLUMINA\tPI:NA" > rg.txt
    samtools merge -rh rg.txt -l 9 --threads 48 ${SAMPLE}.bam *.bam
  cd -
done
