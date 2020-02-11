#!/bin/bash
# david noteborn
# BCF calling dmv slurm (standaard 8 cores)
# roep mij aan met `./bcfcall.sh [mogelijke sample naam] [aantal threads(-1)]`
[ $# -gt 0 ] && sample=$1 || sample=GMI-4_41656
[ $# -gt 1 ] && threads=$2 || threads=8
# --max-depth is standaard gehouden, indien niet goed werkt afbuigen naar beneden
if [ "$sample*.bam" = "$(echo "$sample"*.bam)" ];then
 sbatch -D $PWD -c $((threads+1))<<< '#!/bin/bash
#SBATCH --job-name=bcf-"'"$sample"'"
#SBATCH --output="'"$sample"'".bcf.out
bcftools mpileup -I -Ou -f $HOME/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa "'"$sample"'"*.bam | bcftools call --threads '$threads' --skip-variants indels -mv -Ob  -P 1.1e-4 -o "'"$sample"'".bcf
$HOME/telegramhowto.R "Varianten van '"$sample"' zijn geteld (dmv bcf)."'
else
 echo "$sample*.bam" bestaat niet.
fi
