#!/bin/bash

# roep mij aan met `sbatch -n48 spark-haplo.sh`

#SBATCH --job-name=spark-haplo
#SBATCH --output=spark-haplo.out

/home/david.noteborn/gatk-4.1.3.0/gatk HaplotypeCallerSpark -R REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa -I C0910_41662.sort.bam -ERC GVCF -O C0910_41662.spark-haplo.vcf --spark-master local[24]
