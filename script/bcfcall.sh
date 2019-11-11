#!/bin/bash
# david noteborn
# BCF calling dmv slurm (standaard 8 cores)
# roep mij aan met `./bcfcall.sh [mogelijke sample naam] [aantal threads (deelbaar door 2)]`
[ $# -gt 0 ] && sample=$1 || sample=GMI-4_41656
[ $# -gt 1 ] && threads=$2 || threads=8
# --max-depth is standaard gehouden, indien niet goed werkt afbuigen naar beneden
sbatch -c $threads<<< '#!/bin/bash
#SBATCH --job-name=bcf-'$sample'
#SBATCH --output='$sample'.bcf.out
export R_TELEGRAM_BOT_invadersBot="939730741:AAHnRC-oDDSMJ_qjqmsxcrfcfWkJ6uaXm28"
bcftools mpileup -I -Ou -f REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa '$sample'.sort.bam | bcftools call --threads '$threads' --skip-variants indels -mv -Ob  -P 1.1e-4 -o '$sample'.bcf
Rscript telegramhowto.R "Varianten van '$sample' zijn geteld (dmv bcf)."'
