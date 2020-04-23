#!/bin/bash
# changing invaders
# script for creation of a SNP database
# by david
sbatch <<< '#!/bin/bash
#SBATCH --job-name=maak-DB
export R_TELEGRAM_BOT_invadersBot="TOKEN"
rm onenucleotide_three.db
bcftools view merge3.bcf|python3 bewerk_bcf.py | cat maak_drie.sql - | sqlite3 onenucleotide_three.db
[ $? -ne 0 ] && Rscript telegramhowto.R "$(ls -t ~/slurm-*.out|head -1|xargs cat)" || Rscript telegramhowto.R "Database with three individuals is made"'
