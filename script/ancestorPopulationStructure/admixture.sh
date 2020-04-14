#!/bin/bash
# david
# changing invaders
# requires a plink bed/bim/fam file
[ $# -gt 0 ] && sample=$1 || sample=merge3
[ $# -gt 1 ] && voorouders=$2 || voorouders=4
[ $# -gt 2 ] && runs=$3 || runs=10
[ $# -gt 3 ] && seed=$4 || seed=469
[ $# -gt 4 ] && threads=$5 || threads=4
sbatch -c $threads -D $PWD<<< '#!/bin/bash
#SBATCH --job-name='$voorouders'-'$runs'admixture
#SBATCH --output=logs/admixture-"'"$sample"'"-'$voorouders'.out
$HOME/admixture*/admixture "'"$sample"'".bed '$voorouders' --seed='$seed' -j'$threads' --cv='$runs' && {
 [ -e "'"$sample"'".'$voorouders'.Q ]    && mv "'"$sample"'".'$voorouders'.Q      "'"$sample"'"-admixt.'$voorouders'.Q
 [ -e "'"$sample"'".'$voorouders'.P ]    && mv "'"$sample"'".'$voorouders'.P      "'"$sample"'"-admixt.'$voorouders'.P
 [ -e "'"$sample"'".'$voorouders'.Q_bias ]&&mv "'"$sample"'".'$voorouders'.Q_bias "'"$sample"'"-admixt.'$voorouders'.Q_bias
 [ -e "'"$sample"'".'$voorouders'.Q_se ] && mv "'"$sample"'".'$voorouders'.Q_se   "'"$sample"'"-admixt.'$voorouders'.Q_se
 $HOME/telegramhowto.R "structuur is bepaald voor '"$sample"' met '$voorouders' voorouders."
 true
} || {
 $HOME/telegramhowto.R "tijdens bepalen structuur toch error: $(cat logs/admixture-"'"$sample"'"-'$voorouders'.out)"
}'
