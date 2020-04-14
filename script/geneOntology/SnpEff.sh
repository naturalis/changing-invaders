#!/bin/bash
# david
# changing invaders
# is een bcf bestand voor nodig
[ $# -gt 0 ] && sample=$1 || sample=merge8
if [ -e "$sample.bcf" ];then
sbatch -D $PWD <<< '#!/bin/bash
#SBATCH --job-name=snpEFF
#SBATCH --output=snpEFF.log
bcftools view "'"$sample.bcf"'"|java -Xmx4g -jar $HOME/snpEff/snpEff.jar -t -noLog Rnor_6.0.86| sed "s/ANN=\([^,]*MODIFIER[^,]*,\)*/ANN=/g"| sed "s/ANN=\([^,]*MODIFIER[^,]*,\)*/ANN=/"| sed "s/ANN=\([^,]*[^&]synonymous_variant[^,]*,\)*/ANN=/"|grep -v "ANN=[0-9]" | bcftools view -Ob > "'"$sample.ann.bcf"'" && {
 $HOME/telegramhowto.R "SNP gen annotatie voor '"$sample"' opgeslagen."
 true
} || {
 $HOME/telegramhowto.R "tijdens annoteren met genen toch error: $(cat snpEFF.log)"
}'
else
 echo "$sample.bcf" bestaat niet
fi
