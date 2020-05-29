#!/bin/bash
# david
# changing invaders
# requires a bcf file
[ $# -gt 0 ] && sample=$1 || sample=merge8
[ $# -gt 1 ] && introns=$2 || introns=false
# by the parameter expansion only the esisting files are printed
# head -1 makes sure only the first one is printed
sample_full="$(ls $sample.{bcf,vcf{,.gz}}|head -1)"
if [ $(ls $sample.{bcf,vcf{,.gz}} 2>/dev/null|wc -l) -gt 1 ];then
 echo warning multiple files are named $sample:"$(ls $sample.{bcf,vcf{,.gz}} 2>/dev/null)", we currently are going to annotate "$sample_full"
fi
if [ -n "$sample_full" ];then
sbatch -D $PWD <<< '#!/bin/bash
#SBATCH --job-name=snpEFF
#SBATCH --output=snpEFF.log
# shows the sample file (default merge8) hand over to snpEff, that uses the 86 annotation of ensmbl, where synonimous variants are not used
# also introns are by default not included, which is not usefull for only-SNP-data
bcftools view "'"$sample_full"'"|java -Xmx4g -jar $HOME/snpEff/snpEff.jar -noLog Rnor_6.0.86 -no synonymous_coding -no-intergenic $(if test "'"$introns"'" = "false";then echo -no intron;fi) -no SYNONYMOUS_START -no SYNONYMOUS_STOP|egrep "^#|ANN=" | bcftools view -Ob > "'"${sample_full/./.ann.}"'" && {
 # ends with true, so that an error in sending a message does not secondly tries to send a message that there was an error
 $HOME/telegram_message.R "SNP gene annotation for '"$sample"' saved.";true
} || {
 $HOME/telegram_message.R "during annotation with genes still error: $(cat snpEFF.log)"
}'
else
 echo "$sample."'{bcf,vcf{,.gz}' does not exist
fi
