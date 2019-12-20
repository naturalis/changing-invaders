#!/bin/bash
# david noteborn
# haploide calling dmv Queue
# (en 16 cores op de hpc)
# roep mij aan met `./hapcall-queue.sh [mogelijke sample naam]`
[ $# -gt 0 ] && sample=$1 || sample=GMI-4_41656
if [ "$sample*.bam" != "$(echo "$sample"*.bam)" ];then
sbatch <<< '#!/bin/bash
#SBATCH --job-name=hap-"'"$sample"'"
#SBATCH --output="'"$sample"'".out
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/david.noteborn/lib"
java -Djava.io.tmpdir=tmp -jar $HOME/gatk*/Queue.jar -jobRunner Drmaa -S haplotypeCaller.scala -R $HOME/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa -I "'"$sample"'"*.bam -O "'"$sample"'".g.vcf -nsc 16 -run
Rscript $HOME/telegramhowto.R "Varianten van '$sample' zijn geteld."'
else
 echo $sample.bam bestaat niet
fi
