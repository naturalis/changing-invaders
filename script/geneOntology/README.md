# Gene Ontology
These are scripts that are executed around genes.
There are a lot scripts that obtain data back by filtering on GO terms. (back\*.sh)
Also there is a script to calculate(cluster_genotypes.R)/ generate(all_coding_genotypes.sh) data for MCA analysis over genotypes
And the script to annotate SNPs is also included (SNPEff.sh)
This folder does also contain older scripts to make a distiction between (on)gene mutations(within_gene.R) and (on)exon mutations(within_exon.R).

for the flowchart: all_coding_genotypes is not displayed as a bug in the chart, within\* scripts are not displayed for not being used in current flow, and basically half-depricated.
Also a half-read script to find GO-terms using a R package is written in GO_terms.R
![flowchart](../../doc/flowchart/geneOntology.png?raw=true)
