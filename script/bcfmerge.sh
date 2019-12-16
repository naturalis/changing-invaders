#!/bin/bash
# door david
# Naturalis
# changing invaders
# eerste argument filter over de bcf bestanden
# combineer bcf bestanden tot een
[ $# -eq 1 ] && samples=$(ls *.bcf|grep $1) || samples=$(ls *.bcf|grep -v merge)
[ $# -eq 2 ] && samples=$(ls $1)
getal=$(($(<<<"$samples" grep merge|sed -E s/.*merge\(\[0-9\]+\).bcf/\\1/|tr \\n +|sed s/+$//)+$(<<<"$samples" grep -vc merge)))
sbatch -D $PWD -n2<<< '#!/bin/bash
#SBATCH --job-name=merge" "'$getal'
bcftools merge --threads 2 -0 -m snps -Ob '$samples' -o merge'$getal'.bcf && \
Rscript $HOME/telegramhowto.R "'$(cut -d_ -f1<<<"$samples"|tr \\n ,|sed -e 's/,$//' -e 's/,/& /g'|rev|sed 's/,/ne /'|rev)' zijn gecombineerd tot één"||\
Rscript $HOME/telegramhowto.R "Combineren tot merge'$getal'.bcf mislukt"'
