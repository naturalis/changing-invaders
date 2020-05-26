#!/bin/bash
# by david
# Naturalis
# changing invaders
# calculate consensus genome
[ $# -gt 0 ] && sample=$1 || sample=R7129_41659
bam="$(ls "$sample"*.bam "$HOME/$sample"*.bam 2>/dev/null|head -1)"
if [ "" != "$bam" ];then
sbatch -D $PWD<<< '#!/bin/bash
#SBATCH --job-name=con"'"$sample"'"
trap '\''$HOME/telegramhowto.R "Something goes wrong during creation of '"$sample"' consensus sequence at line $LINENO (commando: $(sed -n $LINENO"p" "$BASH_SOURCE"))";exit 2'\'' ERR
bcftools mpileup -f $HOME/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa "'"$bam"'" | bcftools call -mv -Oz  -o "'"$sample"'".calls.vcf.gz
# the tabix program is part of the htslib package, so one could install this,
# for current use the program is put in the home directory, please change the path accordingly
$HOME/tabix "'"$sample"'".calls.vcf.gz
bcftools consensus "'"$sample"'".calls.vcf.gz -f $HOME/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa > "'"$sample"'".cns.fa && {
 $HOME/telegramhowto.R "Out of '"$sample"' a consensus sequence is made"
}'
else
 echo "$sample*".bam does not exist.
fi
