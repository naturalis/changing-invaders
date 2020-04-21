#!/bin/bash
# door david
# Naturalis
# changing invaders
# blast sequences
# and extract then only sequences with 1 hit
shopt -s extglob
[ $# -gt 0 ] && fasta=$1 || fasta=filtered_snps.fasta
[ $# -gt 1 ] && threads=$2 || threads=25
[ $# -gt 2 ] && db=$3 || db=R7129_41659.cns.fa
# the user can fill in the full fasta name, but also the begin of the name or the name without fasta/fa
# the user could specify a fule from the path they currently is or a full path or from users HOME
# the latter does not need to be specified exactly by the user
fasta="$(ls "$fasta"*{,.{fa,fasta}} "$HOME/$fasta"*{,.{fa,fasta}} 2>/dev/null|head -1)"
# what applies to the fasta file applies the same for the database
db="$(ls "$db"*{,.{fa,fasta}} "$HOME/$db"*{,.{fa,fasta}} 2>/dev/null|head -1)"
# if all parameters are correctly filled,
if [ "" != "$fasta" ];then
 if [ "" != "$db" ];then
  if [[ "$threads" =~ ^[0-9]+$ ]];then
   # out is the output file with all single occuring sequences
   [ $# -gt 3 ] && out=$4 || { out="${fasta//?(*\/|.fa|.fasta)/}";[ -d blast_output ]&&out="blast_output/$out";} # only fasta name without path of extension
   sbatch -D $PWD -n $threads<<< '#!/bin/bash
#SBATCH --job-name=blast-"'"$fasta"'"
#SBATCH --output="'"${out%_*}_${db%%_*}.json"'" # output naam = filtered_snps_R7129.json
date > "'"${out%_*}_${db%%_*}.date"'"
# blast with max 4 chromosome hits and 4 hits per chromosome
blastn -gapopen 20 -gapextend 4 -num_threads '$threads' -outfmt 13 -max_target_seqs 4 -max_hsps 4 -query "'"$fasta"'" -db "'"$db"'" && {
	$HOME/telegramhowto.R "'"$fasta"' is BLASTed! ($(date))";true
} || {
	$HOME/telegramhowto.R "Something goes wrong during BLASTing of '"$fasta"' sequences($(date))";exit
}
# create a numlines file out of which could be determined how many hits there approximately are by extracting the 'num', and 'query' lines out of the fasta
# search first on 'num' or query id, so one gets for every qeury id(SNP pair) all chromosomes and hits within a line with num followed by a number
# search now on '1', or query_id and the line before so first nums and SNP pairs
# does not the line contains two - characters, delete the first 10 to 14 spaces of the line else reject that line
# count the number of lines after a qeury line and show that number alongside the query line. This will be 2 (never less)
# cut on _ and display the second part; Because a SNP has two flanking regions (before and after) every two lines are combined to one, seperated by ,
# if a line contains two commas, save it in blast_output/numlines(db name).txt
egrep '\''"num"|"query_id"'\'' "'"${out%_*}_${db%%_*}.json"'" |egrep -B1 " 1,|query_id"| sed -En '\''/--/!s/ {10,14}//p'\'' | awk -F\" '\''BEGIN{a="";b=0}/query/{if (a!=""){print a","b;b=0};a=$4}/num/{b++}END{print a","b}'\''|cut -d_ -f2 |sed -ne N\;s/\\n/,/ -e "/,.*,/p" > blast_output/numlines_"'"${db%%_*}"'".txt
# dertemine what SNPs have more than 1 hit inside one or both sequences and extract them out the fasta file by use of numlines and save under a new name
# search all lines with 2 times a 2 (minimum number of hist when there is 1) take the fist field seperated on ,
# pun an _ before and a " after every line. Combine every line, but put inbetween an | (and replace the last one)
# search the numbers that are found in the json file and show these lines + the line after (that you save becuase the title is written in there)
# split the line on " and take the 4th part (SNP pair) and search these in the fasta file(and take the line therafter too, which is the real sequence.)
# remove -- lines (seperation line for grep)
egrep "^([0-9]+,2,?){2}$" blast_output/numlines_"'"${db%%_*}"'".txt|cut -d, -f1|sed "s/.*/_&\"/"|tr \\n \||sed "s/|$//" |egrep -f - "'"${out%_*}_${db%%_*}.json"'" -A1|grep title|cut -d\" -f4|grep -f- "'"$fasta"'" -A1|grep -v ^--\$ > "'"${out%_*}_${db%%_*}.fasta"'"
Rscript $HOME/blast_output.R "'"${out%_*}_${db%%_*}"'"
# display the information to the user
HOME/telegramhowto.R "There are $(($(wc -l "'"${out%_*}_${db%%_*}.fasta"'"|cut -d" " -f1)/4)) SNPs left."
# check whether there are samples that are not BLASTed yet
# show all files in blast_output that end on .fasta and get the part of the name that reflects the samplename
# show all files ending on .cns.fa, seperate them on _ so only the sample part of the filename remains
# remove all samplenames from the second list that are displayed in the first and het from the remaining the first (if there is at all).
next=$(ls *.cns.fa|cut -d_ -f1|grep -v "$(ls blast_output/*.fasta|rev|cut -d_ -f1|rev|cut -d. -f1)"|head -1)
# if that is not empty, BLAST that sample in that case
if [ ! -z "$next" ];then $HOME/blast_all_primers.sh "'"${out%_*}_${db%%_*}.fasta"'" '$threads' $next*.cns.fa;else $HOME/telegramhowto.R "Everything is BLASTed";fi
date >> "'"${out%_*}_${db%%_*}.date"'"'
  else
   echo "2nd argument must be a number of threads, this does not seem like a BLAST interpretable number."
  fi
 else
  echo "$db" does not exists.
 fi
else
 echo "$fasta*".bam does not exist.
fi
