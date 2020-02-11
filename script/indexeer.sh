#!/bin/bash
# indexeer een (bam)sample
# changing invaders
# David
[ $# -gt 0 ] && sample=$1 || sample=GMI-4_41656
if [ "$sample*.bam" != "$(echo "$sample"*.bam)" ];then
sbatch -D $PWD<<< '#!/bin/bash
#SBATCH --job-name=index:"'"$sample"'"
## cp ../rutger.vos/fileserver/projects/B19005-525/Samples/"'"$sample/$sample"'".bam .
samtools index "'"$sample"'"*.bam
$HOME/telegramhowto.R "'"$sample"' is geindexeerd"'
else
 echo "$sample*".bam bestaat niet "(in $PWD)".
fi

