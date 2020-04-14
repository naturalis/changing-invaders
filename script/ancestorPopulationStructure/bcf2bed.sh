#!/bin/bash
# david
# changing invaders
# script to convert a bcf file to a een bed file
[ $# -gt 0 ] && sample=$1 || sample=merge3
# [[ "$sample" =~ .bcf$ ]]&&echo contains extension||sample="$sample.bcf"
# only when it exsist
if [ -e "$sample.bcf" -o -e "$sample.vcf" ];then
sbatch -D $PWD <<< '#!/bin/bash
#SBATCH --job-name=bcf2bed
#SBATCH --output=bcf2bed.out
# --geno added
$HOME/plink $([ -e -e "'"$sample.bcf"'" ]&& echo --bcf "'"$sample"'".bcf||echo --vcf "'"$sample"'".vcf) --memory 5100 --geno --keep-allele-order --const-fid 0 --allow-extra-chr 0 --make-bed --out "'"$sample"'" && {
 $HOME/telegramhowto.R "[vb]cf file is converted"
} || {
 $HOME/telegramhowto.R "during conversion error"
}'
else
 echo "$sample.bcf (of $sample.vcf)" does not exsist.
fi
