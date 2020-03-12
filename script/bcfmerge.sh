#!/bin/bash
# door david
# Naturalis
# changing invaders
# eerste argument filter over de bcf bestanden
# combineer bcf bestanden tot een
[ $# -eq 1 ] && samples=$(ls *.bcf|grep $1) || samples=$(ls *.bcf|grep -v merge)
[ $# -eq 2 ] && samples=$(ls $1)
# neem uit alle samples het sample waarvan de naam merge bevat haal hieruit het getal en plaats +tekens tussen verschillende
# neem het aantal samples - degene die merge in de naam hebben
# zie beide als een grote som en tel alles bij elkaar op
getal=$(($(<<<"$samples" grep merge|sed -E s/.*merge\(\[0-9\]+\).bcf/\\1/|tr \\n +|sed s/+$//)+$(<<<"$samples" grep -vc merge)))
sbatch -D $PWD -n2<<< '#!/bin/bash
#SBATCH --job-name=merge" "'$getal'
 bcftools merge --threads 2 -0 -m snps -Ob '$samples' -o merge'$getal'.bcf && {
 # scheidt samplenamen op _ en neem het eerste deel, vervang regeleinde door , (komma spatie) (en de laatste door niks) en de laatste door "en"
 $HOME/telegramhowto.R "'$(cut -d_ -f1<<<"$samples"|tr \\n ,|sed -e 's/,$//' -e 's/,/& /g'|rev|sed 's/,/ne /'|rev)' zijn gecombineerd tot één"
} || {
 $HOME/telegramhowto.R "Combineren tot merge'$getal'.bcf mislukt"
}'
