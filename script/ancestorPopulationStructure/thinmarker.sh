#!/bin/bash
# david
# changing invaders
# prune the markers in the file
[ $# -gt 0 ] && sample=$1 || sample=merge3
# only when it exists
if [ -e "$sample.bed" ];then
sbatch -D $PWD <<< '#!/bin/bash
#SBATCH --job-name=thinmarker
#SBATCH --output=thinmarker.out
# --geno added
$HOME/plink --memory 5100 --bfile "'"$sample"'" --indep-pairwise 50 10 0.1
$HOME/plink --memory 5100 --bfile "'"$sample"'" --extract plink.prune.in --make-bed --out "'"$sample"'".pruned && {
 $HOME/telegramhowto.R "bed file is pruned";true
} || {
 $HOME/telegramhowto.R "during pruning error"
}'
else
 echo "$sample.bed" does not exsist.
fi
