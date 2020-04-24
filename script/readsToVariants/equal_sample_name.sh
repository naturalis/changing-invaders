#!/bin/bash
# Naturalis
# changing invaders
# by david
# put the samplenames right in the bam file so haplotypecaller will not crash
for sample in ../r*.v*/fileserver/projects/B19005-525/Samples/*;do
 # runs a sbatch job
 sbatch <<< '#!/bin/bash
  # replace the header sample name (else gatk wont become happy)
  samtools addreplacerg -R NA -m overwrite_all '$sample/${sample##*/}'.bam -o '$sample/${sample##*/}'.gh.bam
  # move back
  mv '$x/${sample##*/}'.gh.bam '$sample/${sample##*/}.bam
done
