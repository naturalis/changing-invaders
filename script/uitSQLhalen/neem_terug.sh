#!/bin/bash
# changing invaders
# by david
# neem_terug
# om de gefilterde rijen (opgeslagen in UPOS) terug op te slaan in vcf
sbatch -D $PWD <<< '#!/bin/bash
#SBATCH --job-name=neem_terug
sqlite3 zeven_of_meer.db < $HOME/neem_terug_v2.sql && \
Rscript $HOME/telegramhowto.R "Gefilterde SNPs terug opgeslagen in los bestand" || \
Rscript $HOME/telegramhowto.R "tijdens opslaan van gefilterde SNPs is een error opgetreden"'
