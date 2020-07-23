# BLAST SNP flanking regions

To know whether a SNP would be a good candidate for KASP, the flanking regions of the SNP are BLASTed against consensus genomes. First the filtered SNP flanking regions should be extracted as fasta (db2FoCaPfasta.R). Then BLASTing is done. This is done by two scripts. However because one can BLAST against all consensus genomes at once, or just one, two scripts are made: blast_primers.sh (for one consensus genome) and blast_primers_all_samples.sh (for BLASTing all consensus genomes). blast_output.R is the second script that checks whether an alignment actually contains a INDEL (insetion/deletion), since primers will not align with gaps. (As one can see this is a bit too conservative and actually might have a way bigger gap cost to resolve this problem).
See also the flowchart:
![flowchart](../../doc/flowchart/blastSNPs.png?raw=true)

# scripts arguments/input
- blast_output.R:
  - the fasta/json file (without extension). (output will be the modified fasta) (defaults __blast_output/filtered_R6750__)
- blast_primers_all_samples.sh/blast_primers.sh:
  1. query fasta file (with or without extension) (defaults to __filtered_snps.fasta__)
  2. number of threads that blast uses (defaults to __25__)
  3. (fasta) database blasted to (defaults to __the first .cns.(fa|fasta) file in the current directory__)
- db2FoCaPfasta.R:
  - the commandline argument is the used database (defaults to the __globbing of /d\*/d\*/eight.db__)
  - multiple environment variables are used if available:
    1. COVERAGE_MIN, the minimum value for coverage (defaults __16__)
    2. COVERAGE_MAX, the maximum value for coverage (defaults __110__)
    3. QUALITY, the maximum value for coverage (defaults __99__)
    4. DISTANCE, the maximum value for coverage (defaults __250__)
  - output files: data/FOCAP.csv (the filtered positions) data/filtered_snps.csv (filtered sequences) data/filtered_snps.fasta (filtered sequences in fasta)
- iupac_add.sh:
  - one environment variable is used: SILENT (for outputting more or less)
  - input fasta is the first argument (by default __data/filtered_snps.fasta__), input SNP database is the second argument (by default __data/eight.db__) the ouput is the third argument (by default __*input fasta without.fasta*\_iupac.fasta__)
