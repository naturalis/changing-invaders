#!/bin/bash
# by david
# Naturalis
# changing invaders
# calculate consensus genome
[ $# -gt 0 ] && sample=$1 || sample=R7129_41659
bam="$(ls "$sample"*.bam "$HOME/$sample"*.bam 2>/dev/null|head -1)"
# obtain the reference genome, if it is exported using 'export REF' in bash, use that file
# if not, check if it can find a file called files.yml, this is looked up in the directory of this
# script and two directories higher in data/files.yml (as it is structured in github)
# if one of these locations has the file, use the path in that file, else use a hard coded path
[ "$REF" = "" ] && {
 [ -e "$(dirname "$0")/files.yml" ] && yaml="$(dirname "$0")/files.yml"
 [ -e "$(dirname "$0")/../../data/files.yml" ] && yaml="$(dirname "$0")/../../data/files.yml"
 [ "" != "$yaml" ] && REF="$(grep -Po '(?<=filtered: ).*' "$yaml")" || REF="$HOME/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa"
}
if [ "" != "$bam" ];then
sbatch -D $PWD<<< '#!/bin/bash
 #SBATCH --job-name=con"'"$sample"'"
 trap '\''$HOME/telegram_message.R "Something goes wrong during creation of '"$sample"' consensus sequence at line $LINENO (commando: $(sed -n $LINENO"p" "$BASH_SOURCE"))";exit 2'\'' ERR
 bcftools mpileup -f "'"$REF"'" "'"$bam"'" | bcftools call -mv -Oz  -o "'"$sample"'".calls.vcf.gz
 # the tabix program is part of the htslib package, so one could install this,
 # for current use the program is put in the home directory, please change the path accordingly
 $HOME/tabix "'"$sample"'".calls.vcf.gz
 bcftools consensus "'"$sample"'".calls.vcf.gz -f "'"$REF"'" > "'"$sample"'".cns.fa && {
  $HOME/telegram_message.R "Out of '"$sample"' a consensus sequence is made"
}'
else
 echo "$sample*".bam does not exist.
fi
