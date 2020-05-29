#!/bin/bash
# david
# changing invaders
# requires a plink bed/bim/fam file
[ $# -gt 0 ] && sample=$1 || sample=merge3
[ $# -gt 1 ] && ancestors=$2 || ancestors=4
[ $# -gt 2 ] && runs=$3 || runs=10
[ $# -gt 3 ] && seed=$4 || seed=469
[ $# -gt 4 ] && threads=$5 || threads=4
sbatch -c $threads -D $PWD<<< '#!/bin/bash
#SBATCH --job-name='$ancestors'-'$runs'admixture
#SBATCH --output=logs/admixture-"'"$sample"'"-'$ancestors'.out
$HOME/admixture*/admixture "'"$sample"'".bed '$ancestors' --seed='$seed' -j'$threads' --cv='$runs' && {
 [ -e "'"$sample"'".'$ancestors'.Q ]    && mv "'"$sample"'".'$ancestors'.Q      "'"$sample"'"-admixt.'$ancestors'.Q
 [ -e "'"$sample"'".'$ancestors'.P ]    && mv "'"$sample"'".'$ancestors'.P      "'"$sample"'"-admixt.'$ancestors'.P
 [ -e "'"$sample"'".'$ancestors'.Q_bias ]&&mv "'"$sample"'".'$ancestors'.Q_bias "'"$sample"'"-admixt.'$ancestors'.Q_bias
 [ -e "'"$sample"'".'$ancestors'.Q_se ] && mv "'"$sample"'".'$ancestors'.Q_se   "'"$sample"'"-admixt.'$ancestors'.Q_se
 $HOME/telegram_message.R "structuur is determined for '"$sample"' with '$ancestors' ancestors."
 true
} || {
 $HOME/telegram_message.R "during determing structure still error: $(cat logs/admixture-"'"$sample"'"-'$ancestors'.out)"
}'
