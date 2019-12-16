# changing-invaders
Scripts and config files for assembly and SNP design of genomics of Polynesian rats

verklaring scripts/eplanation scripts:

* fastp.pl: trim reads
* minimap2.pl: map reads op referentie genoom/map reads on reference genome
* merge.sh: voeg bam files van hetzelfde individu samen/combine bam files of the same sample
* gelijk_sample_naam.sh: herschijf de sample naam/rewrite sample name (every file as a slurm job)
* sorteer.sh: sorteer/sort fist argument may be sample name
* indexeer.sh: indexeer/index fist argument may be sample name
* haplotypeCaller.scala: scala file to allow scatter/gather multithreading for haplotype calling, this file is taken from gatk forums but lines minimized, this could be more but it is enough to get the job done
* hapcall-queue.sh: script to call variants for a sample (which could be first argument) using Drmaa library it will submit jobs to the slurm system
* bewerk_vcf.py: vcf bestand (eerste argument) naar meer kolommen en lege waardes ipv ., haal header weg, voeg grootste ALT lengte toe/vcf file (first argument) to more columns and empty values instead of ., remove header, add biggest ALT size
* maak_ander.sql: maak een database van de output van vorige bestand, roep aan dmv `sqlite3 onenucleotide.db < maak_ander.sql` andere maak*sql werken niet op de data van haplotype caller/create database of the output of the previous file
* maak_database.sh: koppel bewerk_vcf aan maak_ander
* snp_vinden.py: laat REF zien van alle SNPs in de database van vorige stap/show REF of all SNPs in the database of previous step

vervolgens bcfindex.sh -> bcfmerge.sh
* bcfindex.sh: indexeer het bcf bestand
* bcfmerge.sh: combineer bcf bestanden tot een groter bestand
