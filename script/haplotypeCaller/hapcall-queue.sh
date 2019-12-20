#!/bin/bash
# david noteborn
# haploide calling dmv Queue
# (en 16 cores op de hpc)
# roep mij aan met `./hapcall-queue.sh [mogelijke sample naam]`
[ $# -gt 0 ] && sample=$1 || sample=GMI-4_41656
sbatch <<< '#!/bin/bash
#SBATCH --job-name=hap-'$sample'
#SBATCH --output='$sample'.out
cd gatk*
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/david.noteborn/lib"
export R_TELEGRAM_BOT_invadersBot="939730741:AAHnRC-oDDSMJ_qjqmsxcrfcfWkJ6uaXm28"
java -Djava.io.tmpdir=tmp -jar Queue.jar -jobRunner Drmaa -S haplotypeCaller.scala -R ../REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa -I ../'$sample'.sort.bam -O ../'$sample'.g.vcf -nsc 16 -run
Rscript telegramhowto.R "Varianten van '$sample' zijn geteld."'
