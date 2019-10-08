#!/bin/bash
# door david noteborn
# Naturalis
# superviced door Rutger Vos
cd ~
# download gatk
wget https://github.com/broadinstitute/gatk/releases/download/4.1.3.0/gatk-4.1.3.0.zip
# unzip it
unzip gatk-*.zip
rm gatk-*.zip
# maak index voor R. Norvegicus fasta
wget https://github.com/broadinstitute/picard/releases/download/2.20.8/picard.jar
java -jar picard.jar CreateSequenceDictionary R=REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa.gz
gunzip REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa.gz
samtools faidx REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa
# haplotype calling
# duurt wel lang
# dit voor ieder bestand in volgende versie
samtools index ../rutger.vos/fileserver/projects/B19005-525/Samples/C0910_41662/C0910_41662.bam
# sed -i 's/\.gz$/sta/' Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.dict
# uiteindelijk dit:
# ./gatk*/gatk HaplotypeCaller -R REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa -I ../rutger.vos/fileserver/projects/B19005-525/Samples/C0910_41662/C0910_41662.bam -O C0910_41662.vcf --emit-ref-confidence GVCF
