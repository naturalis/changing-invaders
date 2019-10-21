# changing-invaders
Scripts and config files for assembly and SNP design of genomics of Polynesian rats

verklaring scripts/eplanation scripts:

* fastp.pl: trim reads
* minimap2.pl: map reads op referentie genoom/map reads on reference genome
* merge.sh: voeg bam files van hetzelfde individu samen/combine bam files of the same sample
* hapcall.sh: herschijf de sample naam, sorteer, indexeer en call SNPs en indels/rewrite sample name, sort, index and call SNPs and indels
* bewerk_vcf.py: vcf bestand (eerste argument) naar meer kolommen en lege waardes ipv ., haal header weg, voeg grootste ALT lengte toe/vcf file (first argument) to more columns and empty values instead of ., remove header, add biggest ALT size
* maak.sql: maak een database van de output van vorige bestand, roep aan dmv `sqlite3 onenucleotide.db < maak.sql`
/create database of the output of the previous file
* snp_vinden.py: laat REF zien van alle SNPs in de database van vorige stap/show REF of all SNPs in the database of previous step
