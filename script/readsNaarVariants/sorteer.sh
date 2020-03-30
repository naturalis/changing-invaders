#!/bin/bash
# changing invaders
# by david
# sorteer een bestand (kopieer eerst naar huidig mapje)
[ $# -gt 0 ] && sample=$1 || sample=GMI-4_41656
sbatch -D $PWD<<< '#!/bin/bash
#SBATCH --job-name="'"$sample"'"
b=/home/rutger.vos/fileserver/projects/B19005-525/Samples/"'"$sample/$sample"'".bam
[ $(ls -l $b |sed s/\ +/\ /g|cut -d\  -f5) -gt 100 ] && cp $b .
samtools sort -o '$sample'.sort.bam "'"$sample"'".bam
[ -e "'"$sample"'".sort.bam ] && rm "'"$sample".bam'" || rm "'"$sample"'".sort.bam.*
$HOME/telegramhowto.R "'"$sample"' is gesorteerd"'
