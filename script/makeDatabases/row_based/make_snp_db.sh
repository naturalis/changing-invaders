#!/bin/bash
# changing invaders
# by david
# create SNP database
[ $# -gt 0 ] && directory=$1 || directory=/home/rutger.vos/fileserver/projects/B19005-525/Samples/
[ $# -gt 1 ] && samples=$(ls $directory/*.bcf|egrep $2) || samples=$(ls {/data/d*.n*/L0235_41658,/home/d*.n*/sample-files/{C0910_41662,GMI-4_41656,L0234_41660,R14018_41657,R7129_41659,R6750_41661,P0041_41663}}.bcf)
[ $# -gt 2 ] && number=$3 || number=1

sbatch -D $PWD <<< '#!/bin/bash
#SBATCH --job-name=DB-seq
database=eight.db

shopt -s extglob
number='$number'
[ "$number" = 1 ] && {
	[ -e $database ] && rm $database
	sqlite3 $database < $HOME/make_snp.sql
	[ -e sample-enum.csv ]&&rm sample-enum.csv
	$HOME/telegramhowto.R "Database is generated (without real content)"
}
for sample in '$samples';do
 if [ -e "$sample" ];then
  if [ -s "$sample" ];then
   echo "${sample%.*},$number" >> sample-enum.csv
   bcftools view "$sample"|python3 $HOME/edit_snp.py $number|cat $HOME/add_bcf.sql -|sqlite3 $database
   [ $? -ne 0 ] && { $HOME/telegramhowto.R "$(ls -t ~/slurm-*.out|head -1|xargs cat)";exit;} || $HOME/telegramhowto.R "In the database ${sample//*(*\/|.*)} is also present."
   $HOME/telegramhowto.R "Database is now $(du -h $database|cut -d $'\''\t'\'' -f1|sed -e "s/G/ gigabyte/" -e "s/M/ megabyte/") in size"
   number=$((number+1))
  else
   $HOME/telegramhowto.R "Database could not import $sample because it does not contain any content."
  fi
 else
  $HOME/telegramhowto.R "Database could not import $sample because it is not found on the exact location."
 fi
done
$HOME/telegramhowto.R "Database completely filled... (Now only making of UPOS)"
sqlite3 $database < $HOME/fill_upos.sql
$HOME/telegramhowto.R "Even UPOS filled, fill in as third argument next time $number ."
echo fill in the next time as number $number :\)'
