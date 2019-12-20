#!/bin/sh
sbatch <<< '#!/bin/bash
export R_TELEGRAM_BOT_invadersBot="939730741:AAHnRC-oDDSMJ_qjqmsxcrfcfWkJ6uaXm28"
rm onenucleotide.db
python3 bewerk_vcf.py gatk-4.1.3.0/C0910_41662.sort.g.vcf.gz gzip | cat maak_ander.sql - | sqlite3 onenucleotide.db
[ $? -ne 0 ] && Rscript telegramhowto.R "$(ls -t ~/slurm-*.out|head -1|xargs cat)" || Rscript telegramhowto.R "Database is aangemaakt"'
