#!/bin/bash
# david
# changing invaders
# is een plink bed/bim/fam bestand voor nodig
# en python2
[ $# -gt 0 ] && sample=$1 || sample=merge3
[ $# -gt 1 ] && voorouders=$2 || voorouders=4
[ $# -gt 2 ] && seed=$3 || seed=469
[ $# -gt 3 ] && threads=$4 || threads=1
if [ -e "$sample.bim" -a -e "$sample.bed" -a -e "$sample.fam" ];then
sbatch -D $PWD -n $threads<<< '#!/bin/bash
#SBATCH --job-name='$voorouders'faststructure
#SBATCH --output=logs/faststructure-"'"$sample"'"-'$voorouders'.out
python2 $HOME/proj/fastStructure/structure.py -K '$voorouders' --input="'"$sample"'" --output="'"$sample"'"-struct --seed='$seed' --prior=logistic && {
 mv "'"$sample"'"-struct.'$voorouders'.log logs/
 $HOME/telegramhowto.R "structuur is bepaald voor '"$sample"' met '$voorouders' voorouders."
 true
} || {
 $HOME/telegramhowto.R "tijdens bepalen structuur toch error: $(cat faststructure-"'"$sample"'"-'$voorouders'.out)"
}'
else
 echo "$sample.bim, $sample.bed en/of $sample.fam" bestaat niet
fi
