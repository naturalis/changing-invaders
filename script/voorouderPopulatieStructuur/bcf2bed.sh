#!/bin/bash
# david
# changing invaders
# script om een bcf bestand om te zetten naar een bed bestand
[ $# -gt 0 ] && sample=$1 || sample=merge3
# [[ "$sample" =~ .bcf$ ]]&&echo contains extension||sample="$sample.bcf"
# enkel wanneer het bestaat
if [ -e "$sample.bcf" -o -e "$sample.vcf" ];then
sbatch -D $PWD <<< '#!/bin/bash
#SBATCH --job-name=bcf2bed
#SBATCH --output=bcf2bed.out
# --geno toegevoegd
$HOME/plink $([ -e -e "'"$sample.bcf"'" ]&& echo --bcf "'"$sample"'".bcf||echo --vcf "'"$sample"'".vcf) --memory 5100 --geno --keep-allele-order --const-fid 0 --allow-extra-chr 0 --make-bed --out "'"$sample"'" && {
 $HOME/telegramhowto.R "[vb]cf bestand is omgezet"
} || {
 $HOME/telegramhowto.R "tijdens omzetten error"
}'
else
 echo "$sample.bcf (of $sample.vcf)" bestaat niet.
fi
