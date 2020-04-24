#!/bin/bash
# changing invaders
# by David
# index a (bam)sample
[ $# -gt 0 ] && sample=$1 || sample=GMI-4_41656
if [ "$sample*.bam" != "$(echo "$sample"*.bam)" ];then
sbatch -D $PWD<<< '#!/bin/bash
#SBATCH --job-name=index:"'"$sample"'"
## cp ../r*.v*/fileserver/projects/B19005-525/Samples/"'"$sample/$sample"'".bam .
samtools index "'"$sample"'"*.bam
$HOME/telegramhowto.R "'"$sample"' is indexed"'
else
 echo "$sample*".bam does not exist "(in $PWD)".
fi

