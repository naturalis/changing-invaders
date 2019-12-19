#!/bin/bash
# door david
# Naturalis
# changing invaders
# blast sequenties
shopt -s extglob
date
[ $# -gt 0 ] && fasta=$1 || fasta=filtered_snps_seq.fa
[ $# -gt 1 ] && threads=$2 || threads=8
[ $# -gt 2 ] && db=$3 || db=R7129_41659.cns.fa
fasta="$(ls "$fasta"*{,.{fa,fasta}} "$HOME/$fasta"*{,.{fa,fasta}} 2>/dev/null)"
db="$(ls "$db"*{,.{fa,fasta}} "$HOME/$db"*{,.{fa,fasta}} 2>/dev/null|head -1)"
if [ "" != "$fasta" ];then
 if [ "" != "$db" ];then
  if [[ "$threads" =~ ^[0-9]+$ ]];then
   [ $# -gt 3 ] && out=$4 || out="${fasta//?(*\/|.fa|.fasta)/}" # enkel fasta naam zonder pad of extensie
   sbatch -D $PWD -n $threads<<< '#!/bin/bash
#SBATCH --job-name=blast-"'"$fasta"'"
#SBATCH --output="'"$out.json"'"
blastn -num_threads '$threads' -outfmt 13 -max_target_seqs 20 -max_hsps 20 -query "'"$fasta"'" -db "'"$db"'" && \
Rscript $HOME/telegramhowto.R "'"$fasta"' is geblast! ($(date))"||
Rscript $HOME/telegramhowto.R "Iets fout gedaan tijdens het blasten van '"$fasta"' sequenties($(date))"
date'
  else
   echo "2 argument moet een aantal threads zijn, dit lijkt niet op een voor blast interpreteerbaar getal."
  fi
 else
  echo "$db" bestaat niet.
 fi
else
 echo "$fasta*".bam bestaat niet.
fi
