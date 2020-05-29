#!/bin/bash
# changing invaders
# by david
# script to generate a SNP database
[ $# -gt 0 ] && sample=$1 || sample=merge8
if [ -e "$sample".bcf ];then
 sbatch -D $PWD <<< '#!/bin/bash
#SBATCH --job-name=make-DB-8
rm onenucleotide_eight.db
bcftools view "'"$sample"'".bcf|python3 $HOME/edit_eight.py | cat $HOME/make_eight.sql - | sqlite3 onenucleotide_eight.db
[ $? -ne 0 ] && $HOME/telegram_message.R "$(ls -t slurm-*.out|head -1|xargs cat)" || $HOME/telegram_message.R "Database with eight individuals is created"'
else
 echo "$sample".bcf does not exist
fi
