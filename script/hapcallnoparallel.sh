sample=C0910_41662
sbatch <<< '#!/bin/bash
./gatk*/gatk HaplotypeCaller -R 'REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa' -I '$sample'.sort.bam -ERC GVCF -O '$sample':8.g.vcf
Rscript telegramhowto.R "'$sample'.g.vcf is klaar voor gebruik"'
