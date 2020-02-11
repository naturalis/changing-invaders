#!/bin/bash
# door david
# Naturalis
# changing invaders
# blast sequenties
# en extraheer vervolgens enkel sequenties met 1 hit
shopt -s extglob
[ $# -gt 0 ] && fasta=$1 || fasta=filtered_snps.fasta
[ $# -gt 1 ] && threads=$2 || threads=25
[ $# -gt 2 ] && db=$3 || db=R7129_41659.cns.fa
fasta="$(ls "$fasta"*{,.{fa,fasta}} "$HOME/$fasta"*{,.{fa,fasta}} 2>/dev/null|head -1)"
db="$(ls "$db"*{,.{fa,fasta}} "$HOME/$db"*{,.{fa,fasta}} 2>/dev/null|head -1)"
if [ "" != "$fasta" ];then
 if [ "" != "$db" ];then
  if [[ "$threads" =~ ^[0-9]+$ ]];then
   [ $# -gt 3 ] && out=$4 || { out="${fasta//?(*\/|.fa|.fasta)/}";[ -d blast_output ]&&out="blast_output/$out";} # enkel fasta naam zonder pad of extensie
   sbatch -D $PWD -n $threads<<< '#!/bin/bash
#SBATCH --job-name=blast-"'"$fasta"'"
#SBATCH --output="'"${out%_*}_${db%%_*}.json"'" # output naam = filtered_snps_R7129.json
date > "'"${out%_*}_${db%%_*}.date"'"
# blast met maximaal 4 chromosoom hits en 4 hits per chromosoom
blastn -gapopen 20 -gapextend 4 -num_threads '$threads' -outfmt 13 -max_target_seqs 4 -max_hsps 4 -query "'"$fasta"'" -db "'"$db"'" && {
	$HOME/telegramhowto.R "'"$fasta"' is geblast! ($(date))";true
} || {
	$HOME/telegramhowto.R "Iets fout gedaan tijdens het blasten van '"$fasta"' sequenties($(date))"
	exit
}
# maak een numlines bestand aan waaruit kan worden achterhaald hoeveel hits er ongeveer zijn
egrep '\''"num"|"query_id"'\'' "'"${out%_*}_${db%%_*}.json"'" |egrep -B1 " 1,|query_id"| sed -En '\''/--/!s/ {10,14}//p'\'' | awk -F\" '\''BEGIN{a="";b=0}/query/{if (a!=""){print a","b;b=0};a=$4}/num/{b++}END{print a","b}'\''|cut -d_ -f2 |sed -ne N\;s/\\n/,/ -e "/,.*,/p" > blast_output/numlines_"'"${db%%_*}"'".txt
# achterhaal welke SNPs meer dan 1 hit hebben in een of beide sequenties en haal deze uit het fasta bestand, en sla op onder nieuwe naam
egrep "^([0-9]+,2,?){2}$" blast_output/numlines_"'"${db%%_*}"'".txt|cut -d, -f1|sed "s/.*/_&\"/"|tr \\n \||sed "s/|$//" |egrep -f - "'"${out%_*}_${db%%_*}.json"'" -A1|grep title|cut -d\" -f4|grep -f- "'"$fasta"'" -A1|grep -v ^--\$ > "'"${out%_*}_${db%%_*}.fasta"'"
Rscript $HOME/blast_output.R "'"${out%_*}_${db%%_*}"'"
# geef de informatie terug aan de gebruiker
$HOME/telegramhowto.R "Er zijn $(($(wc -l "'"${out%_*}_${db%%_*}.fasta"'"|cut -d" " -f1)/4)) SNPs over."
volgende=$(ls *.cns.fa|cut -d_ -f1|grep -v "$(ls blast_output/*.fasta|rev|cut -d_ -f1|rev|cut -d. -f1)"|head -1)
if [ ! -z "$volgende" ];then $HOME/blast_all_primers.sh "'"${out%_*}_${db%%_*}.fasta"'" '$threads' $volgende*.cns.fa;else $HOME/telegramhowto.R "Alles is geBLAST";fi
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
