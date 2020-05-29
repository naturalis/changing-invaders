#!/bin/bash
# david
# changing invaders
# index consensus
# requires a consensus genome
[ $# -gt 0 ] && sample=$1 || sample=GMI-4_41656
if [ -e "$sample".cns.fa ];then
 makeblastdb -in "$sample".cns.fa -dbtype nucl && {
  $HOME/telegram_message.R "index for $sample is made";true
 } || {
  $HOME/telegram_message.R "during fasta indexing still an error"
 }
else
 echo "$sample.cns.fa" does not exist.
fi
