#!/bin/bash
# script voor het aanmaken van een SNP database
# door david
# changing invaders
# maak een SNP database
[ $# -gt 0 ] && map=$1 || map=/home/rutger.vos/fileserver/projects/B19005-525/Samples/
[ $# -gt 1 ] && samples=$(ls $map/*.bcf|egrep $2) || samples=$(ls {/data/david.noteborn/L0235_41658,/home/rutger.vos/fileserver/projects/B19005-525/Samples/{C0910_41662,GMI-4_41656,L0234_41660,R14018_41657,R6750_41661,P0041_41663}}.bcf)
[ $# -gt 2 ] && getal=$3 || getal=1

sbatch -D $PWD <<< '#!/bin/bash
#SBATCH --job-name=DB-seq
database=zeven_of_meer.db
shopt -s extglob

getal='$getal'
[ "$getal" = 1 ] && {
	[ -e $database ] && rm $database
	sqlite3 $database < $HOME/maak_snp.sql
	Rscript $HOME/telegramhowto.R "Database is aangemaakt (zonder nog echt inhoud)"
}
for sample in '$samples';do
 if [ -e "$sample" ];then
  if [ -s "$sample" ];then
   echo "${sample%.*},$getal" >> sample-enum.csv
   bcftools view "$sample"|python3 $HOME/bewerk_snp.py $getal|cat $HOME/voeg_bcf_toe.sql -|sqlite3 $database
   [ $? -ne 0 ] && { Rscript $HOME/telegramhowto.R "$(ls -t ~/slurm-*.out|head -1|xargs cat)";exit;} || Rscript $HOME/telegramhowto.R "In de database is nu ook ${sample//*(*\/|.*)} aanwezig."
   Rscript $HOME/telegramhowto.R "Database is dus nu $(du -h $database|cut -d $'\''\t'\'' -f1|sed -e "s/G/ gigabyte/" -e "s/M/ megabyte/") groot"
   getal=$((getal+1))
  else
   Rscript $HOME/telegramhowto.R "Database kon $sample niet importeren omdat het geen inhoud bevat."
  fi
 else
  Rscript $HOME/telegramhowto.R "Database kon $sample niet importeren omdat het niet gevonden is op de huidige locatie."
 fi
done
Rscript $HOME/telegramhowto.R "Database volledig gevuld... (Nu nog UPOS maken)"
sqlite3 $database < $HOME/vulupos.sql
Rscript $HOME/telegramhowto.R "Zelfs UPOS gevuld, vul de volgende keer bij derde argument $getal in."
echo vul de volgende keer bij getal $getal in :\)'
