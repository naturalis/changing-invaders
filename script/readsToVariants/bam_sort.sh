#!/bin/bash
# changing invaders
# by david
# sort a bam file (copy first to current folder)
# notice the use of the sample variable in two scopes
[ $# -gt 0 ] && sample=$1 || sample=GMI-4_41656
sbatch -D $PWD<<< '#!/bin/bash
#SBATCH --job-name="'"$sample"'"
sample=/home/rutger.vos/fileserver/projects/B19005-525/Samples/"'"$sample/$sample"'".bam
# if the size is bigger than 100 bytes copy
# longlist the sample, by replacing multiple spaces the fifth field will be the samplefile size
[ $(ls -l $sample |sed s/\ +/\ /g|cut -d\  -f5) -gt 100 ] && cp $sample .
samtools sort -o '$sample'.sort.bam "'"$sample"'".bam
[ -e "'"$sample"'".sort.bam ] && rm "'"$sample".bam'" || rm "'"$sample"'".sort.bam.*
$HOME/telegramhowto.R "'"$sample"' is sorted"'
