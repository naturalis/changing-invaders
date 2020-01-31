#!/bin/bash
# david
# changing invaders
# prune the markers in the file
[ $# -gt 0 ] && sample=$1 || sample=merge3
# enkel wanneer het bestaat
if [ -e "$sample.bed" ];then
sbatch -D $PWD <<< '#!/bin/bash
#SBATCH --job-name=thinmarker
#SBATCH --output=thinmarker.out
# --geno toegevoegd
$HOME/plink --memory 5100 --bfile "'"$sample"'" --indep-pairwise 50 10 0.1
$HOME/plink --memory 5100 --bfile "'"$sample"'" --extract plink.prune.in --make-bed --out "'"$sample"'".pruned && {
 $HOME/telegramhowto.R "bed bestand is gepruned";true
} || {
 $HOME/telegramhowto.R "tijdens pruning error"
}'
else
 echo "$sample.bed" bestaat niet.
fi
