#!/bin/bash
# david noteborn
# haploide calling dmv Queue
# (en 44 cores op de hpc)
# roep mij aan met `sbatch hapcall-queue.sh`

#SBATCH --job-name=que-haplo
#SBATCH --output=hello-queue.out
cd gatk*
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/home/david.noteborn/lib"
sample=C0910_41662
java -Djava.io.tmpdir=tmp -jar Queue.jar -jobRunner Drmaa -S haplotypeCaller.scala -R ../REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa -I ../$sample.sort.bam -O ../$sample:q.g.vcf -nsc 44 -run
