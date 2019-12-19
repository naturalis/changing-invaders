#!/bin/bash
# door david
# Naturalis
# changing invaders
# blast sequenties
# en extraheer vervolgens enkel sequenties met 1 hit
shopt -s extglob
[ $# -gt 0 ] && fasta=$1 || fasta=filtered_snps_seq.fasta
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
#SBATCH --output="'"${out%_*}_${db%%_*}.json"'" # output naam = filtered_snps_R7129.json
date > "'"${out%_*}_${db%%_*}.date"'"
blastn -num_threads '$threads' -outfmt 13 -max_target_seqs 20 -max_hsps 20 -query "'"$fasta"'" -db "'"$db"'" && {
	Rscript $HOME/telegramhowto.R "'"$fasta"' is geblast! ($(date))"
} || {
	Rscript $HOME/telegramhowto.R "Iets fout gedaan tijdens het blasten van '"$fasta"' sequenties($(date))"
	exit
}
egrep '\''"num"|"query_id"'\'' "'"${out%_*}_${db%%_*}.json"'" |egrep -B1 " 1,|query_id"| sed -En '\''/--/!s/ {10,14}//p'\'' | awk -F\" '\''BEGIN{a="";b=0}/query/{if (a!=""){print a","b;b=0};a=$4}/num/{b++}END{print a","b}'\''|cut -d_ -f2 |sed -ne N\;s/\\n/,/ -e "/,.*,/p" > blast_output/numlines_"'"${db%%_*}"'".txt
egrep "^([0-9]+,2,?){2}$" blast_output/numlines_"'"${db%%_*}"'".txt|cut -d, -f1|sed "s/.*/_&"/"|tr \\n \||sed "s/|$//" |egrep -f - "'"${out%_*}_${db%%_*}.json"'" -A1|grep title|cut -d\" -f4|grep -f- "'"$fasta"'" -A1|grep -v "^--$" > "'"${out%_*}_${db%%_*}.fasta"'"
Rscript $HOME/telegramhowto.R "Er zijn $(($(wc -l "'"${out%_*}_${db%%_*}.fasta"'"|cut -d' ' -f1)/4)) SNPs over."
date >> "'"${out%_*}_${db%%_*}.date"'"'
  else
   echo "2 argument moet een aantal threads zijn, dit lijkt niet op een voor blast interpreteerbaar getal."
  fi
 else
  echo "$db" bestaat niet.
 fi
else
 echo "$fasta*".bam bestaat niet.
fi
