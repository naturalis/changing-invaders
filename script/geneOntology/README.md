# Gene Ontology
These are scripts that are executed around genes.
There are a lot scripts that obtain data back by filtering on GO terms. (back\*.sh)
Also there is a script to calculate(cluster_genotypes.R)/ generate(all_coding_genotypes.sh) data for MCA analysis over genotypes
And the script to annotate SNPs is also included (SNPEff.sh)
This folder does also contain older scripts to make a distiction between (on)gene mutations(within_gene.R) and (on)exon mutations(within_exon.R). For the 3D figures, the montage program (part of imagemagick) and the ffmpeg program should be installed and accessible for R. (and techincally showimage, but is not required for a working figure)

for the flowchart: all_coding_genotypes is not displayed as a bug in the chart, within\* scripts are not displayed for not being used in current flow, and basically half-depricated.
Also a half-read script to find GO-terms using a R package is written in GO_terms.R
![flowchart](../../doc/flowchart/geneOntology.png?raw=true)

# scripts arguments/input
many (and all back... scripts) require a merge8.ann.vcf file in the working directory
- within_gene.R:
  - the input is always stdin. (output will be stdout)
- back_statistics.sh/back_stat.sh:
  - the argument as input is the ontological group one wants the mutations from. (output will be stdout) (default **Anatomical structure morphogenesis**)
- back_track.sh:
  - The input is by a dialog window, the output by stdout. (output will be stdout) (default **Anatomical structure morphogenesis**)
- cluster_genotypes.sh:
  - The input is the genotypes files (output will be genotype file but end on _msa.png and .mca) (defaults **asks for your choice(s) of the .gt files in the current directory**)
- mca_combined.sh:
  - The input is the genotypes files (output will be MCA_report.png) (defaults **asks for your choices(or choice) of the .gt files in the current directory**)
- GO_terms.R:
  - The input is a file with amounts and genes (output will be go-terms.csv and stdout) (defaults **amountGeneWithExon.csv**)
- pos2fasta.R:
  - The input argument is a file with selected SNP positions is a file with amounts and genes, also it requires a reference genome either described in the environment variable REF, or in the home directory/REF/Rattus, etc. (output will be *input without extension*.fasta and the blasted filtered fasta's) (defaults **selected_snps.pos**)
- SNPEff.sh:
  1. sample (bcf/vcf/vcf.gz) file (without extension) (default **merge8**)
  2. whether introns should be kept inside, (default __false__)
  3. the output is the same input file, but .ann within the name
- within_exon.R:
  - the input is a file called merge8_within_gene containing chromosome, position pairs, and rnorvegicus-genes.RData R-data file containing the R. norvegicus genes in a dataframe.
  - the output is in genen-exons.RData, amountGeneWithExon.csv, mutationWithinExon.csv, most-mutated.png, mutation-freq.png
- back_impact.sh:
  - the input is a GO-term, if this is not given using command-line arguments, it will be using a dialog window.
  - the output will be selected_blasted_snps.fasta, a fasta with only blast verified SNPs
- all_coding_genotypes.sh:
  - this script requires merge8.ann.vcf, as an (SNPEff)annotated vcf file, and outputs coding.gt
- relevant_format.sh:
  - this script requires merge8.ann.vcf in a sideways directory, as an (SNPEff)annotated vcf file, and outputs by default __the *inputfile*_ontology.tsv__
  - the input is however the first argument (by default __complete_ng.tsv__)
  - this script requires also a file with the biological processes (globbing of _../gen\*-o\*/GO_BIO\*S_ALL.csv_) and one with the go terms (globbing of _../gen\*-o\*/go-term\*.csv_).
