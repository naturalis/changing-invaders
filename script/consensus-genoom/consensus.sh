#!/bin/bash
# door david
# Naturalis
# changing invaders
# bereken consensus genoom
[ $# -gt 0 ] && sample=$1 || sample=R7129_41659
bam="$(ls "$sample"*.bam "$HOME/$sample"*.bam 2>/dev/null|head -1)"
if [ "" != "$bam" ];then
sbatch -D $PWD<<< '#!/bin/bash
#SBATCH --job-name=con"'"$sample"'"
function fout() {
	$HOME/telegramhowto.R "Iets fout gedaan tijdens het maken van '"$sample"' consensus sequentie"
	exit
}
bcftools mpileup -f $HOME/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa "'"$bam"'" | bcftools call -mv -Oz  -o "'"$sample"'".calls.vcf.gz || fout
$HOME/tabix "'"$sample"'".calls.vcf.gz || fout
bcftools consensus "'"$sample"'".calls.vcf.gz -f $HOME/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa > "'"$sample"'".cns.fa && {
 $HOME/telegramhowto.R "Van '"$sample"' is een consensus sequentie gemaakt";true
} || fout'
else
 echo "$sample*".bam bestaat niet.
fi
