[ $# -gt 0 ] && sample=$1 || sample=GMI-4_41656
sbatch <<< '#!/bin/bash
export R_TELEGRAM_BOT_invadersBot="939730741:AAHnRC-oDDSMJ_qjqmsxcrfcfWkJ6uaXm28"
#SBATCH --job-name='$sample'
## cp ../rutger.vos/fileserver/projects/B19005-525/Samples/'$sample/$sample'.bam .
samtools index '$sample'.sort.bam
Rscript telegramhowto.R "'$sample' is geindexeerd"'
