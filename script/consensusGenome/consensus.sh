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
function fout() {
	$HOME/telegramhowto.R "Something goes wrong during creation of '"$sample"' consensus sequence"
	exit
}
bcftools mpileup -f $HOME/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa "'"$bam"'" | bcftools call -mv -Oz  -o "'"$sample"'".calls.vcf.gz || fout
$HOME/tabix "'"$sample"'".calls.vcf.gz || fout
bcftools consensus "'"$sample"'".calls.vcf.gz -f $HOME/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa > "'"$sample"'".cns.fa && {
 $HOME/telegramhowto.R "Out of '"$sample"' a consensus sequence is made";true
} || fout'
else
 echo "$sample*".bam does not exist.
fi
