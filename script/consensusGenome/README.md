# Consensus
Scripts around the creation of a consensus genome
Both creation as indexing.
As first argument the samplename (without .bam extension)

Consensus genomes are made to check how possible primers would bind on it.
flowchart:
![flowchart](../../doc/flowchart/consensusGenome.png?raw=true)


# scripts arguments/input
- consensus_genome.sh:
  - the commandline argument is the samplename (defaults to __R7129_41659__)
  - the reference genome is used if the location is available:
    1. in the REF environment variable
    2. in the file files.yml in the directory the script is located (defaults __110__)
    3. in the file data/files.yml in the directory the script is located, but moving two folders up (where it is in github)
    4. at last in the directory REF as file Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa in the home directory of the current user
  - output files: *samplename*.calls.vcf.gz (the variant file) *samplename*.cns.fa (the consensus genome in fasta) *samplename*.calls.vcf.gz.tbi (variant index)  
- consensus_index.sh:
  - one argument is used: the samplename (defaults to __GMI-4\_41656__)
  - input fasta is data/filtered_snps.fasta, input SNP database is data/eight.db
  - three files (including the index) are outputed:
    1. *samplename*.cns.fa.nhr
    2. *samplename*.cns.fa.nin
    3. *samplename*.cns.fa.nsq
