#!/bin/bash
# changing invaders
# by David
# index a fasta file
[ $# -gt 0 ] && fasta=$1 || fasta=GMI-4_41656
if [ "$fasta*.fa{,sta}" != "$(echo "$fasta"*.fa{,sta})" ];then
sbatch -D $PWD<<< '#!/bin/bash
#SBATCH --job-name=index:"'"$fasta"'"
samtools faidx "'"$fasta"'"*.fa{,sta}
$HOME/telegram_message.R "'"$fasta"' is indexed"'
else
 echo "$fasta*".fa{,sta} does not exist "(in $PWD)".
fi

