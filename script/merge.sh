#!/bin/bash

#SBATCH --job-name=ci-merge
#SBATCH --output=ci-merge.out

DIR=/home/rutger.vos/fileserver/projects/B19005-525/Samples/
SAMPLES=$(ls ${DIR})
for SAMPLE in ${SAMPLES}; do
  cd "${DIR}/${SAMPLE}"
    BAMS=$(ls *.bam)
    samtools merge -r "@RG\tID:NA\tSM:${SAMPLE}\tPL:ILLUMINA\tPI:NA" -l 9 --threads 48 ${SAMPLE}.bam ${BAMS}
  cd -
done
