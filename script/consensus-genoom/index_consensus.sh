#!/bin/bash
# david
# changing invaders
# indexeer consensus
# is een consensus genoom voor nodig
[ $# -gt 0 ] && sample=$1 || sample=GMI-4_41656
if [ -e "$sample".cns.fa ];then
 makeblastdb -in "$sample".cns.fa -dbtype nucl && {
  Rscript $HOME/telegramhowto.R "index voor $sample gemaakt"
 } || {
  Rscript $HOME/telegramhowto.R "tijdens fasta indexeren toch error"
 }
else
 echo "$sample.cns.fa" bestaat niet.
fi
