#!/bin/bash
# script to convert mousedata in files.yml format and output that file
# download extract
# changing invaders
# Naturalis

# the created mouse directory should be used as data or localdata directory for pipelines
mkdir mouse
cd mouse
wget "https://ndownloader.figshare.com/articles/3219673?private_link=f5d63d8c265a05618137" -O 3219673.zip
unzip 3219673.zip '*.gz' targets2.txt;rm 3219673.zip;mkdir spread
# reads...
for x in *.gz;do mv $x $(grep $x targets2.txt|cut -d$'\t' -f1).fastq.gz;done
mkdir spread/RUN{1..4}
# for every sample
for gzippedfastq in *.gz;do
 gunzip "$gzippedfastq"
 fastq="${gzippedfastq/.gz/}"
 # spread the file in 8 sub tiny files that represent different runs(RUN1 to RUN4) and directions(R1 and R2)
 # every fastq read will be stored in another file, where after one continues to the next, until
 # all reads are used
 sed -n "$(for run in RUN{1..4};do
  for pair in 1 2;do
   echo 's/.*//;N;N;N;N;s/\\n//;w spread/'$run/${fastq/R1/R"$pair"_$run}
  done
 done)" "$fastq"
done
rm *.fastq targets2.txt

# zip every saved file individual
cd spread;for x in *;do cd $x;ls|grep -v files.yml|xargs gzip;cd -;done;cd ..
# reference genome...
reference=Mus_musculus.GRCm38.dna.toplevel.fa
# replace the ending .fa to .filtered.fa
reference_filtered=${reference/%.fa/.filtered.fa}
wget -q ftp://ftp.ensembl.org/pub/release-99/fasta/mus_musculus/dna/$reference.gz
# remove lines with too much unknown
zcat $reference.gz|grep -v 'NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN'|sed '/CHR_MG171_PATCH/Q' |sed -n '/>18/{:k;s/\n//;p;s/.*//;N;/>X/!bk;}'|gzip > $reference_filtered.gz
rm $reference.gz
ln -s $reference_filtered.gz $reference.gz
cd spread
{
 # it still shows 6.0, no matter what genome is used
 echo "---"
 echo "reference:"
 # Mmus for our reference genome
 echo "  ${reference:0:1}$(cut -c1-3 <<<${reference#*_})_6.0: /var/data/data/$reference.gz"
 echo "  ${reference:0:1}$(cut -c1-3 <<<${reference#*_})_6.0-filtered: /var/data/data/$reference_filtered.gz"
 echo "sample:"
 for sample in $(find|grep -Po '(?<=./RUN[1-4]/).*'|cut -d_ -f1|sort|uniq);do
  echo "  $sample:"
  echo "    run:"
  for run in $(ls */"$sample"*|grep -oP "[^_]+(?=\\.fastq)"|sort -u);do
   cd $run
    echo "     $run:"
    echo "       file:"
    echo "         fastp:"
    echo "           - /var/data/data/$run/$(ls "$sample"*R1*"$run"*|sed 's/fastq/fastp.&/')"
    echo "           - /var/data/data/$run/$(ls "$sample"*R2*"$run"*|sed 's/fastq/fastp.&/')"
    echo "         raw:"
    echo "           - /var/data/data/$run/$(ls "$sample"*R1*"$run"*)"
    echo "           - /var/data/data/$run/$(ls "$sample"*R2*"$run"*)"
   cd -> /dev/null # else cd will print the directory to the files.yml file
  done
 done
 # all these lines are added to files.yml, that will be used in the pipeline
} > files.yml
cd ..;mv spread/* .;rmdir spread
