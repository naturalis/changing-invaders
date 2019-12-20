#!/bin/bash
# script voor het aanmaken van een SNP database
# door david
# changing invaders
sbatch <<< '#!/bin/bash
#SBATCH --job-name=maak-DB
export R_TELEGRAM_BOT_invadersBot="939730741:AAHnRC-oDDSMJ_qjqmsxcrfcfWkJ6uaXm28"
rm onenucleotide_drie.db
bcftools view merge3.bcf|python3 bewerk_bcf.py | cat maak_drie.sql - | sqlite3 onenucleotide_drie.db
[ $? -ne 0 ] && Rscript telegramhowto.R "$(ls -t ~/slurm-*.out|head -1|xargs cat)" || Rscript telegramhowto.R "Database met drie individuen is aangemaakt"'
