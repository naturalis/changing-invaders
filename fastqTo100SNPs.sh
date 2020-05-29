#!/bin/bash
# this script is a pipeline from fastq to 100 distant, good quality SNPs
shopt -s extglob
cd /var/data
yaml=data/files.yml
export DISPLAY=:0
# REF=/home/d*n*/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa
export REF="$(grep reference -A2 "$yaml"|grep -Po '(?<=filtered: ).*')" COVERAGE_MIN=0 COVERAGE_MAX=3 QUALITY=2
trap 'echo "something goes wrong, error at line $LINENO (commando: $(sed -n $LINENO"p" "$BASH_SOURCE"))";exit 2' ERR
[ ! -e script/telegramhowto.R ] && echo 'print(commandArgs(TRUE))' > script/telegramhowto.R
perl -I $PWD/lib script/readsToVariants/fastp.pl -file "$yaml"
mkdir -p /root/tmp
# minimize the default memory minimap2 uses to make it work on test environments
sed -i 's/-m 7G/-m 70M/' script/readsToVariants/minimap2.pl
perl -I $PWD/lib script/readsToVariants/minimap2.pl --yaml "$yaml" --index true --outdir /var/data/data --verbose
# put the samplenames in the bam file so haplotypecaller wont crash
for x in /var/data/data/*.bam;do
 # something to file
 samtools addreplacerg -R NA -m overwrite_all "$x" -o "${x%.*}".gh.bam
 # move back
 mv "${x%.*}".gh.bam "${x%.*}".bam
done
# first index the reference genome
samtools faidx "$REF"
# sort
# ls /var/data/data/*.bam|grep '_.*/$'|sed 's/.$//'
# take from the files only the filename (and not directory)
# by searching for a preceded / and then everything except /
# this ended in .bam (without obtaining this extension)
for sample in $(ls /var/data/data/*.bam|grep -Po '(?<=/)[^/]*(?=.bam)'|sort -u);do
 #b=/var/data/data/"$sample/$sample".bam
 b=/var/data/data/"$sample".bam
 # if the size of the file is bigger than 100 bytes/blocks
 [ $(ls -l $b |sed s/\ +/\ /g|cut -d\  -f5) -gt 100 ] && cp $b .
 samtools sort -o "$sample".sort.bam "$sample".bam
 [ -e "$sample".sort.bam ] && rm "$sample.bam" || rm "$sample".sort.bam.*
 # index
 samtools index "$sample"*.bam
 # call SNP varianten
 bcftools mpileup -I -Ou -f "$REF" "$sample"*.bam | bcftools call --threads 2 --skip-variants indels -mv -Ob  -P 1.1e-4 -o "$sample".bcf
done
[ ! -d data/sample-files ] && mkdir data/sample-files
mv *.bcf data/sample-files
# save in database
database=data/eight.db

number=1
[ "$number" = 1 ] && {
	[ -e $database ] && rm $database
	sqlite3 $database < script/makeDatabases/row_based/make_snp.sql
	[ -e data/sample-enum.csv ] && rm data/sample-enum.csv
}
for sample in $(ls data/sample-files/|grep \\.bcf\$);do
 sample_path="data/sample-files/$sample"
 if [ -e "$sample_path" ];then
  if [ -s "$sample_path" ];then
   echo "${sample%.*},$number" >> data/sample-enum.csv
   bcftools view "$sample_path"|python3 script/makeDatabases/row_based/edit_snp.py $number|cat script/makeDatabases/row_based/add_bcf.sql -|sqlite3 $database
   [ $? -ne 0 ] && { echo "$(ls -t ~/slurm-*.out|head -1|xargs cat)";exit;} || echo "In the database ${sample//*(*\/|.bcf)} is now also available."
   echo "Database is now $(du -h $database|cut -d $'\t' -f1|sed -e "s/G/ gigabyte/" -e "s/M/ megabyte/") in size."
   number=$((number+1))
  else
   echo "Database could not import $sample because it contains no content."
  fi
 else
  echo "Database could not import $sample because it is not found in the current location."
  exit
 fi
done
sqlite3 $database < script/makeDatabases/row_based/fill_upos.sql
# extract fasta with filtered positions
Rscript script/blastSNPs/db2FoCaPfasta.R $database

# build consensus
# ls /var/data/data/*.bam|grep '_.*/$'|sed 's/.$//'
for sample in $(ls /var/data/data/*.bam|grep -Po '(?<=/)[^/]*(?=.bam)'|sort -u);do
 bam="/var/data/data/$sample.bam"
 bcftools mpileup -f "$REF" "$bam" | bcftools call -mv -Oz  -o "data/sample-files/$sample".calls.vcf.gz
 /opt/samtools/bin/tabix "data/sample-files/$sample".calls.vcf.gz
 bcftools consensus "data/sample-files/$sample".calls.vcf.gz -f "$REF" > "data/sample-files/$sample".cns.fa
 makeblastdb -in "data/sample-files/$sample".cns.fa -dbtype nucl
done
# BLAST regio's before and after mutation on the consensus genomes of the 8 rats
mkdir -p data/blast_output

blast_primers_all_samples() {
 [ $# -gt 0 ] && fasta=$1 || fasta=data/filtered_snps.fasta
 [ $# -gt 1 ] && threads=$2 || threads=16
 [ $# -gt 2 ] && db=$3 || db="$(ls data/sample-files/*|grep .fa\$|head -1)"
 fasta="$(ls "$fasta"*{,.{fa,fasta}} "data/sample-files/$fasta"*{,.{fa,fasta}} 2>/dev/null|head -1)"
 db="$(ls "$db"*{,.{fa,fasta}} "data/sample-files/$db"*{,.{fa,fasta}} 2>/dev/null|head -1)";db_fp="$db";db="${db##*/}"
 [ $# -gt 3 ] && out=$4 || { out="${fasta//?(*\/|.fa|.fasta)/}";[ -d data/blast_output ]&&out="data/blast_output/$out";} # only fasta name without path or extension
 date > "${out%_*}_${db%%_*}.date"
 # blast with max 4 chromosome hits and 4 hits per chromosome
 # the specification of out is only needed in this version, not the individual script
 blastn -gapopen 20 -gapextend 4 -num_threads $threads -outfmt 13 -max_target_seqs 4 -max_hsps 4 -query "$fasta" -db "$db_fp" -out ${out%_*}_${db%%_*}.json
 cat ${out%_*}_${db%%_*}_*.json > ${out%_*}_${db%%_*}.json;rm ${out%_*}_${db%%_*}_*.json
 Rscript script/telegramhowto.R "$fasta is BLASTed! ($(date))"
 # create a numlines file out of which could be determined how many hits there approximately are by extracting the 'num', and 'query' lines out of the fasta
 # search first on 'num' or query id, so one gets for every qeury id(SNP pair) all chromosomes and hits within a line with num followed by a number
 # search now on '1', or query_id and the line before so first nums and SNP pairs
 # does not the line contains two - characters, delete the first 10 to 14 spaces of the line else reject that line
 # count the number of lines after a qeury line and show that number alongside the query line. This will be 2 (never less)
 # cut on _ and display the second part; Because a SNP has two flanking regions (before and after) every two lines are combined to one, seperated by ,
 # if a line contains two commas, save it in blast_output/numlines(db name).txt
 egrep '"num"|"query_id"' "${out%_*}_${db%%_*}.json" |egrep -B1 " 1,|query_id"| sed -En '/--/!s/ {10,14}//p' | awk -F\" 'BEGIN{a="";b=0}/query/{if (a!=""){print a","b;b=0};a=$4}/num/{b++}END{print a","b}'|cut -d_ -f2 |sed -ne N\;s/\\n/,/ -e "/,.*,/p" > data/blast_output/numlines_"${db%%_*}".txt
 # dertemine what SNPs have more than 1 hit inside one or both sequences and extract them out the fasta file by use of numlines and save under a new name
 # search all lines with 2 times a 2 (minimum number of hist when there is 1) take the fist field seperated on ,
 # pun an _ before and a " after every line. Combine every line, but put inbetween an | (and replace the last one)
 # search the numbers that are found in the json file and show these lines + the line after (that you save becuase the title is written in there)
 # split the line on " and take the 4th part (SNP pair) and search these in the fasta file(and take the line therafter too, which is the real sequence.)
 # remove -- lines (seperation line for grep)
 egrep "^([0-9]+,2,?){2}$" data/blast_output/numlines_"${db%%_*}".txt|cut -d, -f1|sed "s/.*/_&\"/"|tr \\n \||sed "s/|$//" |egrep -f - "${out%_*}_${db%%_*}.json" -A1|grep title|cut -d\" -f4|grep -f- "$fasta" -A1|grep -v ^--\$ > "${out%_*}_${db%%_*}.fasta"
 Rscript script/blastSNPs/blast_output.R "${out%_*}_${db%%_*}"
 # display the information to the user
 remainingSNPs=$(($(wc -l "${out%_*}_${db%%_*}.fasta"|cut -d" " -f1)/4))
 Rscript script/telegramhowto.R "There are $remainingSNPs SNPs left."
 if test $remainingSNPs -eq 0;then echo "becuase of no valid SNPs anymore the program will exit now...";exit;fi
 # check whether there are samples that are not BLASTed yet
 # show all files in blast_output that end on .fasta and get the part of the name that reflects the samplename
 # show all files ending on .cns.fa, seperate them on _ so only the sample part of the filename remains
 # remove all samplenames from the second list that are displayed in the first and het from the remaining the first (if there is at all).
 next=$(ls data/sample-files/*.cns.fa|cut -d_ -f1|grep -v "$(ls data/blast_output/*.fasta|rev|cut -d_ -f1|rev|grep -Po '.+?(?=\.fasta)')"|head -1|rev|cut -d/ -f1|rev)
 # if that is not empty, BLAST that sample in that case
 if [ ! -z "$next" ];then blast_primers_all_samples "${out%_*}_${db%%_*}.fasta" $threads $next;else Rscript script/telegramhowto.R "Everything is BLASTed";fi
 date >> "${out%_*}_${db%%_*}.date"
}
blast_primers_all_samples # a recursive function
Rscript script/SNPextract.R 100 data/eight.db data/sample-enum.csv data/blast_output/ data/SNP_output/ filled # finally recieve the 100 best SNPs
