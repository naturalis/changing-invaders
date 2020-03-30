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
# de gebruiker kan de volledige fasta naam invullen, maar ook het begin van de naam of de naam zonder fasta/fa
# de gebruiker kan een bestand specificeren vanuit het pad waar het zich bevind of een volledig pad of vanuit HOME van de gebruiker
# dit laatste hoeft de gebruiker zelf niet aan te geven
fasta="$(ls "$fasta"*{,.{fa,fasta}} "$HOME/$fasta"*{,.{fa,fasta}} 2>/dev/null|head -1)"
# wat voor het fasta bestand geldt geldt ook voor de database
db="$(ls "$db"*{,.{fa,fasta}} "$HOME/$db"*{,.{fa,fasta}} 2>/dev/null|head -1)"
# als alle parameters kloppen,
if [ "" != "$fasta" ];then
 if [ "" != "$db" ];then
  if [[ "$threads" =~ ^[0-9]+$ ]];then
   # out is het output bestand met alle enkel voorkomende sequenties
   [ $# -gt 3 ] && out=$4 || { out="${fasta//?(*\/|.fa|.fasta)/}";[ -d blast_output ]&&out="blast_output/$out";} # enkel fasta naam zonder pad of extensie
   sbatch -D $PWD -n $threads<<< '#!/bin/bash
#SBATCH --job-name=blast-"'"$fasta"'"
#SBATCH --output="'"${out%_*}_${db%%_*}.json"'" # output naam = filtered_snps_R7129.json
date > "'"${out%_*}_${db%%_*}.date"'"
# blast met maximaal 4 chromosoom hits en 4 hits per chromosoom
blastn -gapopen 20 -gapextend 4 -num_threads '$threads' -outfmt 13 -max_target_seqs 4 -max_hsps 4 -query "'"$fasta"'" -db "'"$db"'" && {
	$HOME/telegramhowto.R "'"$fasta"' is geblast! ($(date))";true
} || {
	$HOME/telegramhowto.R "Iets fout gedaan tijdens het blasten van '"$fasta"' sequenties($(date))";exit
}
# maak een numlines bestand aan waaruit kan worden achterhaald hoeveel hits er ongeveer zijn door de num, en query regels uit de fasta te halen
# zoek eerst op num of query id, zo krijgt men voor iedere qeury id(SNP paar) alle chromosomen en hits daarbinnen een lijn met num en dan een getal
# zoek nu op 1, of query_id en de regel daarvoor dus op eerste nums en SNP paar
# bezit de regel geen twee - teke- dan laat de regel zien, maar vervang eerst eenmalig 10 tot 14 spaties uit de regel
# tel het aantal regels na een qeury regel en geef dat aantal naast de qeury regel weer. Dit kan dus als er 1 hit is nooit minder dan 2 zijn.
# scheidt nu op _ en weergeef het tweede deel; Omdat een SNP twee flanking regios heeft (voor en na) wordt iedere twee regels gecombineerd tot een met een , ertussen
# Als een regel twee kommas bevat, sla hen dan op in numlines.txt
egrep '\''"num"|"query_id"'\'' "'"${out%_*}_${db%%_*}.json"'" |egrep -B1 " 1,|query_id"| sed -En '\''/--/!s/ {10,14}//p'\'' | awk -F\" '\''BEGIN{a="";b=0}/query/{if (a!=""){print a","b;b=0};a=$4}/num/{b++}END{print a","b}'\''|cut -d_ -f2 |sed -ne N\;s/\\n/,/ -e "/,.*,/p" > blast_output/numlines_"'"${db%%_*}"'".txt
# achterhaal welke SNPs meer dan 1 hit hebben in een of beide sequenties en haal deze uit het fasta bestand door gebruik te maken van numlines, en sla op onder nieuwe naam
# vind alle regels met 2 keer een 2 (minimaal aantal als er 1 hit is) neem het eerste veld gescheiden op ,
# zet een _ voor en een " na iedere regel. Combineer iedere regel, maar zet ertussen een | (en vervang die op de laatste)
# zoek de getallen die dus gevonden zijn in het json bestand en laat die regels zien + die regel erna (die je behoud(omdat er title in wordt benoemd))
# scheidt de regel op " en neem het 4e stuk (SNP paar) en zoek die in het fasta bestand(en neem ook de regel daarna, wat dus de echte sequentie is.)
# verwijder -- regels (scheidingsteken voor grep)
egrep "^([0-9]+,2,?){2}$" blast_output/numlines_"'"${db%%_*}"'".txt|cut -d, -f1|sed "s/.*/_&\"/"|tr \\n \||sed "s/|$//" |egrep -f - "'"${out%_*}_${db%%_*}.json"'" -A1|grep title|cut -d\" -f4|grep -f- "'"$fasta"'" -A1|grep -v ^--\$ > "'"${out%_*}_${db%%_*}.fasta"'"
Rscript $HOME/blast_output.R "'"${out%_*}_${db%%_*}"'"
# geef de informatie terug aan de gebruiker
$HOME/telegramhowto.R "Er zijn $(($(wc -l "'"${out%_*}_${db%%_*}.fasta"'"|cut -d" " -f1)/4)) SNPs over."
# kijk op er nog samples zijn die niet geBLAST zijn
# kijk naar alle bestanden in blast_output die eindigen op .fasta en neem het deel van die naam dat de samplenaam weergeeft
# geef alle bestanden weer die eindigen op .cns.fa, scheidt op _ zodat enkel het sample deel van de bestandsnaam overblijft
# verwijder alle samplenamen uit de tweede lijst die voorkomen in de eerste, en neem van de overgeblevene de eerste naam.
volgende=$(ls *.cns.fa|cut -d_ -f1|grep -v "$(ls blast_output/*.fasta|rev|cut -d_ -f1|rev|cut -d. -f1)"|head -1)
# als dat niet leeg is, blast die dan weer
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
