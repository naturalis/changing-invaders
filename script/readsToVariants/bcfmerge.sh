#!/bin/bash
# changing invaders
# by david
# Naturalis
# first argument filter over bcf files
# combine bcf files to one
[ $# -eq 1 ] && samples=$(ls *.bcf|grep $1) || samples=$(ls *.bcf|grep -v merge)
[ $# -eq 2 ] && samples=$(ls $1)
# get from all the samples the sample whose name contains merge (or first argument) extract the number
# get the number of samples - those that have merge in their name
# look to both as a big sum and summarize
getal=$(($(<<<"$samples" grep merge|sed -E s/.*merge\(\[0-9\]+\).bcf/\\1/|tr \\n +|sed s/+$//)+$(<<<"$samples" grep -vc merge)))
sbatch -D $PWD -n2<<< '#!/bin/bash
#SBATCH --job-name=merge" "'$getal'
 bcftools merge --threads 2 -0 -m snps -Ob '$samples' -o merge'$getal'.bcf && {
 # seperate samplenames on _ and get the first part, replace newlines by , (comma space) (and the last one by nothing) and the last one by "and"
 $HOME/telegramhowto.R "'$(cut -d_ -f1<<<"$samples"|tr \\n ,|sed -e 's/,$//' -e 's/,/& /g'|rev|sed 's/,/dna /'|rev)' are combined to one"
} || {
 $HOME/telegramhowto.R "Combining to merge'$getal'.bcf failed"
}'
