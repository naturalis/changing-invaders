# BLAST SNP flanking regions

To know whether a SNP would be a good candidate for KASP, the flanking regions of the SNP are BLASTed against consensus genomes. First the filtered SNP flanking regions should be extracted as fasta (db2FoCaPfasta.R). Then BLASTing is done. This is done by two scripts. However because one can BLAST against all consensus genomes at once, or just one, two scripts are made: blast_primers.sh (for one consensus genome) and blast_primers_all_samples.sh (for BLASTing all consensus genomes). blast_output.R is the second script that checks whether an alignment actually contains a INDEL (insetion/deletion), since primers will not align with gaps. (As one can see this is a bit too conservative and actually might have a way bigger gap cost to resolve this problem).
See also the flowchart:
![flowchart](../../doc/flowchart/blastSNPs.png?raw=true)

# scripts arguments/input
- blast_output.R:
  - the fasta/json file (without extension). (output will be the modified fasta) __(defaults blast_output/filtered_R6750)__
- blast_primers_all_samples.sh/blast_primers.sh:
  1. query fasta file (with or without extension) __(defaults to filtered_snps.fasta)__
  2. number of threads that blast uses __(defaults to 25)__
  3. (fasta) database blasted to __(defaults to the first .cns.(fa|fasta) file in the current directory)__
- db2FoCaPfasta.R:
  - the commandline argument is the used database __(defaults to the globbing of /d\*/d\*/eight.db)__
  - multiple environment variables are used if available:
    1. COVERAGE_MIN, the minimum value for coverage (defaults __16__)
    2. COVERAGE_MAX, the maximum value for coverage (defaults __110__)
    3. QUALITY, the maximum value for coverage (defaults __99__)
    4. DISTANCE, the maximum value for coverage (defaults __250__)
  - output files: data/FOCAP.csv (the filtered positions) data/filtered_snps.csv (filtered sequences) data/filtered_snps.fasta (filtered sequences in fasta)
- iupac_add.sh:
  - one environment variable is used: SILENT (for outputting more or less)
  - input fasta is data/filtered_snps.fasta, input SNP database is data/eight.db
