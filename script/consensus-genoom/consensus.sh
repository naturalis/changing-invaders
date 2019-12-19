#!/bin/bash
# door david
# Naturalis
# changing invaders
# bereken consensus genoom
[ $# -gt 0 ] && sample=$1 || sample=R7129_41659
bam="$(ls "$sample"*.bam "$HOME/$sample"*.bam 2>/dev/null)"
if [ "" != "$bam" ];then
sbatch -D $PWD<<< '#!/bin/bash
#SBATCH --job-name=con-"'"$sample"'"
#bcftools mpileup -f $HOME/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa "'"$bam"'" | bcftools call -mv -Oz  -o "'"$sample"'".calls.vcf.gz
$HOME/tabix "'"$sample"'".calls.vcf.gz
bcftools consensus /data/david.noteborn/"'"$sample"'".calls.vcf.gz -f $HOME/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa > "'"$sample"'".cns.fa && \
Rscript $HOME/telegramhowto.R "Van '"$sample"' is een consensus sequentie gemaakt"||
Rscript $HOME/telegramhowto.R "Iets fout gedaan tijdens het maken van '"$sample"' consensus sequentie"'
else
 echo "$sample*".bam bestaat niet.
fi
