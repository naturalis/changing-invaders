#!/bin/bash
# Naturalis
# changing invaders
# by david noteborn
# put the samplenames right in the bam file so haplotypecaller will not crash
for x in ../rutger.vos/fileserver/projects/B19005-525/Samples/*;do
 # runs a sbatch job
 sbatch <<< '#!/bin/bash
  # replace the header sample name (else gatk wont become happy)
  samtools addreplacerg -R NA -m overwrite_all '$x/${x##*/}'.bam -o '$x/${x##*/}'.gh.bam
  # move back
  mv '$x/${x##*/}'.gh.bam '$x/${x##*/}.bam
done
