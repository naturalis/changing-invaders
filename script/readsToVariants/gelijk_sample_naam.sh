#!/bin/bash
# door david noteborn
# Naturalis
# superviced door Rutger Vos
# zet de samplenamen goed in het bam bestand zodat haplotypecaller niet crashed
for x in ../rutger.vos/fileserver/projects/B19005-525/Samples/*;do
# run een sbatch job
sbatch <<< '#!/bin/bash
# vervang de header sample naam (anders is gatk niet echt happy)
samtools addreplacerg -R NA -m overwrite_all '$x/${x##*/}'.bam -o '$x/${x##*/}'.gh.bam
# verplaats weer terug
mv '$x/${x##*/}'.gh.bam '$x/${x##*/}.bam
done
