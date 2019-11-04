sample=GMI-4_41656
sbatch <<< '#!/bin/bash
#SBATCH --job-name='$sample'
## cp ../rutger.vos/fileserver/projects/B19005-525/Samples/'$sample/$sample'.bam .
samtools index '$sample'.sort.bam
Rscript telegramhowto.R "'$sample' is geindexeerd"'
