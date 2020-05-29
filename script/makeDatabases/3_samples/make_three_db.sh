#!/bin/bash
# changing invaders
# script for creation of a SNP database
# by david
sbatch <<< '#!/bin/bash
#SBATCH --job-name=make-DB
export R_TELEGRAM_BOT_invadersBot="TOKEN"
rm onenucleotide_three.db
bcftools view merge3.bcf|python3 edit_three.py | cat make_three.sql - | sqlite3 onenucleotide_three.db
[ $? -ne 0 ] && Rscript telegram_message.R "$(ls -t ~/slurm-*.out|head -1|xargs cat)" || Rscript telegram_message.R "Database with three individuals is made"'
