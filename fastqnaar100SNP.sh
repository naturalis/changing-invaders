#!/bin/bash
# dit script is een pipeline van fastq naar 100 ver van elkaar af staande, goede kwaliteit SNPs
# TODO:generate nep data
shopt -s extglob
cd /var/data
trap 'echo "something goes wrong, error at line $LINENO (commando: $(sed -n $LINENO"p" "$BASH_SOURCE"))";exit 2' ERR
perl -I $PWD/lib readsNaarVariants/fastp.pl -file "files.yml"
mkdir /root/tmp
perl -I $PWD/lib readsNaarVariants/minimap2.pl --yaml files.yml --index true --outdir /var/data/data --verbose
exit
bash merge.sh
# zet de samplenamen goed in het bam bestand zodat haplotypecaller niet crashed
for x in /home/r*v*/fileserver/projects/B19005-525/Samples/*;do
samtools addreplacerg -R NA -m overwrite_all '$x/${x##*/}'.bam -o '$x/${x##*/}'.gh.bam
# verplaats weer terug
mv $x/${x##*/}.gh.bam $x/${x##*/}.bam
done

# sorteer
for sample in $(ls /home/r*v*/fileserver/projects/B19005-525/Samples/ -p|grep '_.*/$'|sed 's/.$//');do
 b=/home/rutger.vos/fileserver/projects/B19005-525/Samples/"'"$sample/$sample"'".bam
 [ $(ls -l $b |sed s/\ +/\ /g|cut -d\  -f5) -gt 100 ] && cp $b .
 samtools sort -o "$sample".sort.bam "$sample".bam
 [ -e "$sample".sort.bam ] && rm "$sample.bam" || rm "$sample".sort.bam.*
 # indexeer
 samtools index "$sample"*.bam
 # call SNP varianten
 bcftools mpileup -I -Ou -f /home/d*n*/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa "$sample"*.bam | bcftools call --threads 2 --skip-variants indels -mv -Ob  -P 1.1e-4 -o "$sample".bcf
done
mkdir sample-files
mv *.bcf sample-files

# opslaan in database
database=acht.db

getal=1
[ "$getal" = 1 ] && {
	[ -e $database ] && rm $database
	sqlite3 $database < /home/d*n*/maak_snp.sql
	rm sample-enum.csv
}
for sample in $(ls sample-files);do
 if [ -e "$sample" ];then
  if [ -s "$sample" ];then
   echo "${sample%.*},$getal" >> sample-enum.csv
   bcftools view "$sample"|python3 /home/d*n*/bewerk_snp.py $getal|cat /home/d*n*/voeg_bcf_toe.sql -|sqlite3 $database
   [ $? -ne 0 ] && { echo "$(ls -t ~/slurm-*.out|head -1|xargs cat)";exit;} || echo "In de database is nu ook ${sample//*(*\/|.*)} aanwezig."
   echo "Database is dus nu $(du -h $database|cut -d $'\t' -f1|sed -e "s/G/ gigabyte/" -e "s/M/ megabyte/") groot"
   getal=$((getal+1))
  else
   echo "Database kon $sample niet importeren omdat het geen inhoud bevat."
  fi
 else
  echo "Database kon $sample niet importeren omdat het niet gevonden is op de huidige locatie."
 fi
done
sqlite3 $database < /home/d*n*/vulupos.sql
# extraheer fasta met gefilterde posities
Rscript uniek-meer.R $database
# bouw consensus
for sample in $(ls /home/r*v*/fileserver/projects/B19005-525/Samples/ -p|grep '_.*/$'|sed 's/.$//');do
 bam=/home/r*v*/fileserver/projects/B19005-525/Samples/"$sample/$sample.bam"
 bcftools mpileup -f /home/d*n*/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa "$bam" | bcftools call -mv -Oz  -o "$sample".calls.vcf.gz
 /home/d*n*/tabix "$sample".calls.vcf.gz
 bcftools consensus "$sample".calls.vcf.gz -f /home/d*n*/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa > "$sample".cns.fa
 makeblastdb -in "$sample".cns.fa -dbtype nucl
done

# blast regio's voor en na mutatie op de consensus genomen van de 8 ratten
mkdir blast_output
blast_all_primers() {
 [ $# -gt 0 ] && fasta=$1 || fasta=filtered_snps.fasta
 [ $# -gt 1 ] && threads=$2 || threads=16
 [ $# -gt 2 ] && db=$3 || db=R7129_41659.cns.fa
 fasta="$(ls "$fasta"*{,.{fa,fasta}} "/home/d*n*/$fasta"*{,.{fa,fasta}} 2>/dev/null|head -1)"
 db="$(ls "$db"*{,.{fa,fasta}} "/home/d*n*/$db"*{,.{fa,fasta}} 2>/dev/null|head -1)"
 [ $# -gt 3 ] && out=$4 || { out="${fasta//?(*\/|.fa|.fasta)/}";[ -d blast_output ]&&out="blast_output/$out";} # enkel fasta naam zonder pad of extensie
 #SBATCH --job-name=blast-"$fasta"
 #SBATCH --output="${out%_*}_${db%%_*}.json" # output naam = filtered_snps_R7129.json
 date > "${out%_*}_${db%%_*}.date"
 # blast met maximaal 4 chromosoom hits en 4 hits per chromosoom
 blastn -gapopen 20 -gapextend 4 -num_threads '$threads' -outfmt 13 -max_target_seqs 4 -max_hsps 4 -query "$fasta" -db "$db" > "${out%_*}_${db%%_*}.json" && {
  echo "$fasta is geblast! ($(date))";true
 } || {
  echo "Iets fout gedaan tijdens het blasten van $fasta sequenties($(date))"
  exit
 }
 # maak een numlines bestand aan waaruit kan worden achterhaald hoeveel hits er ongeveer zijn
 egrep '"num"|"query_id"' "${out%_*}_${db%%_*}.json" |egrep -B1 " 1,|query_id"| sed -En '/--/!s/ {10,14}//p' | awk -F\" 'BEGIN{a="";b=0}/query/{if (a!=""){print a","b;b=0};a=$4}/num/{b++}END{print a","b}'|cut -d_ -f2 |sed -ne N\;s/\\n/,/ -e "/,.*,/p" > blast_output/numlines_"${db%%_*}".txt
 # achterhaal welke SNPs meer dan 1 hit hebben in een of beide sequenties en haal deze uit het fasta bestand, en sla op onder nieuwe naam
 egrep "^([0-9]+,2,?){2}$" blast_output/numlines_"${db%%_*}".txt|cut -d, -f1|sed "s/.*/_&\"/"|tr \\n \||sed "s/|$//" |egrep -f - "${out%_*}_${db%%_*}.json" -A1|grep title|cut -d\" -f4|grep -f- "$fasta" -A1|grep -v ^--\$ > "${out%_*}_${db%%_*}.fasta"
 Rscript /home/d*n*/blast_output.R "${out%_*}_${db%%_*}"
 # geef de informatie terug aan de gebruiker
 echo "Er zijn $(($(wc -l "${out%_*}_${db%%_*}.fasta"|cut -d" " -f1)/4)) SNPs over."
 volgende=$(ls *.cns.fa|cut -d_ -f1|grep -v "$(ls blast_output/*.fasta|rev|cut -d_ -f1|rev|cut -d. -f1)"|head -1)
 if [ ! -z "$volgende" ];then blast_all_primers "${out%_*}_${db%%_*}.fasta" $threads $volgende*.cns.fa;else echo "Alles is geBLAST";fi
 date >>"${out%_*}_${db%%_*}.date"
}
blast_all_primers # een recursieve functie
Rscript SNPstats.R # verkrijg de uiteindelijke 100 beste SNPs
