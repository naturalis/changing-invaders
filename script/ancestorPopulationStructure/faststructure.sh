#!/bin/bash
# david
# changing invaders
# requires a plink bed/bim/fam file
# and python2
[ $# -gt 0 ] && sample=$1 || sample=merge3
[ $# -gt 1 ] && ancestors=$2 || ancestors=4
[ $# -gt 2 ] && seed=$3 || seed=469
[ $# -gt 3 ] && threads=$4 || threads=1
if [ -e "$sample.bim" -a -e "$sample.bed" -a -e "$sample.fam" ];then
sbatch -D $PWD -n $threads<<< '#!/bin/bash
#SBATCH --job-name='$ancestors'faststructure
#SBATCH --output=logs/faststructure-"'"$sample"'"-'$ancestors'.out
python2 $HOME/proj/fastStructure/structure.py -K '$ancestors' --input="'"$sample"'" --output="'"$sample"'"-struct --seed='$seed' --prior=logistic && {
 mv "'"$sample"'"-struct.'$ancestors'.log logs/
 $HOME/telegramhowto.R "structure is determined for '"$sample"' with '$ancestors' anchestors.";true
} || {
 $HOME/telegramhowto.R "during determination structure still error: $(cat faststructure-"'"$sample"'"-'$voorouders'.out)"
}'
else
 echo "$sample.bim, $sample.bed and/or $sample.fam" does not exsist
fi
