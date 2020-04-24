#!/bin/bash
# changing invaders
# by david
# bcf calling by the use of slurm (default 8 cores)
# callwith `./bcf_call.sh [possible sample name] [number of threads(-1)]`
[ $# -gt 0 ] && sample=$1 || sample=GMI-4_41656
[ $# -gt 1 ] && threads=$2 || threads=8
# --max-depth default is used, if not working reducing to something lower
if [ "$sample*.bam" = "$(echo "$sample"*.bam)" ];then
 sbatch -D $PWD -c $((threads+1))<<< '#!/bin/bash
#SBATCH --job-name=bcf-"'"$sample"'"
#SBATCH --output="'"$sample"'".bcf.out
bcftools mpileup -I -Ou -f $HOME/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa "'"$sample"'"*.bam | bcftools call --threads '$threads' --skip-variants indels -mv -Ob  -P 1.1e-4 -o "'"$sample"'".bcf
$HOME/telegramhowto.R "Variants of '"$sample"' are called (using bcf)."'
else
 echo "$sample*.bam" does not exist.
fi
