#!/usr/bin/env Rscript
# get all positions witin genes and check whether they fall within exons
# then get all genes and explain how many mutations are really 'coding'
# changing invaders
# by david
library(future.apply, quietly = TRUE)
library(future.batchtools)
library(biomaRt)
library(ggplot2)
plan(batchtools_slurm, workers = 12)
Sys.time()
setwd("~/gene-ontology/")
positions_with_mutations <- read.table("merge8_within_gene", header = FALSE, col.names=c("CHR", "POS"))
load("rnorvegicus-genes.RData")
genes_info <- genes_info[-grep("X|Y", genes_info$chromosome_name),]
genes_info$before_position <- ifelse(genes_info$strand > 0, genes_info$start_position, genes_info$end_position)
genes_info$after_position  <- ifelse(genes_info$strand > 0, genes_info$end_position, genes_info$start_position)

# first we take all genes away that won't have a SNP anyway

gene_has_snp <- future_apply(genes_info, 1, function(gene) any(positions_with_mutations$CHR==gene["chromosome_name"]&gene["voor_position"]<=positions_with_mutations$POS&positions_with_mutations$POS<=gene["na_position"]))
table(gene_has_snp)
# next we  look what SNPs fall in exons
# for this we download the start and stop position of the exons
# the r. norvegicus database is used
ensembl = useDataset("rnorvegicus_gene_ensembl", mart = useMart("ensembl"))
genes_exon <- getBM(attributes = c('ensembl_gene_id', 'chromosome_name', 'exon_chrom_start', 'exon_chrom_end', 'ensembl_exon_id'),
                   filters = 'ensembl_gene_id',
                   values = genes_info[, "ensembl_gene_id"], #gene_has_snp
                   mart = ensembl)
save(file = "genen-exons.RData", genes_exon)
# all not exon positions are stored
non_exon <- future_apply(positions_with_mutations, 1, function(chr_pos) any(genes_exon$exon_chrom_start <= chr_pos["POS"] & chr_pos["POS"] <= genes_exon$exon_chrom_end & genes_exon$chromosome_name == chr_pos["CHR"]))
table(non_exon)
# all not exon mutations are removed
positions_within_exon <- positions_with_mutations[non_exon,]
# next all genes are removed where not an mutation occurs in the exons
gene_within_exon_mutation <- genes_info[future_apply(genes_info, 1, function(gene) any(positions_within_exon$CHR==gene["chromosome_name"]&gene["voor_position"]<=positions_within_exon$POS&positions_within_exon$POS<=gene["na_position"])),]
table(gene_within_exon_mutation)
# how many mutations are then within the exons from a gene found
amount_gene <- Reduce(rbind, future_apply(gene_within_exon_mutation, 1, function(gene) data.frame(gene = gene["ensembl_gene_id"], amount = sum(positions_within_exon$CHR==gene["chromosome_name"]&gene["voor_position"]<=positions_within_exon$POS&positions_within_exon$POS<=gene["na_position"]), stringsAsFactors = FALSE)))
write.table(amount_gene, "amountGeneWithExon.csv", row.names = FALSE)
write.table(positions_within_exon, "mutationWithinExon.csv", row.names = FALSE)
table(amount_gene$amount)
# more than 85 mutations are displayed in a plot
often_occurs <- amount_gene[amount_gene$amount > 85,]
ggplot(often_occurs, aes(gene, amount)) + geom_col() + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + ggtitle("How many times there are SNPs", subtitle = "on the SNP richest genes")
ggsave("most-mutated.png")
# how many times a X time mutation occurs in this plot
ggplot(as.data.frame(table(amount_gene$amount)), aes(Var1, Freq)) + geom_col() + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + ggtitle("How many times does a X times SNPs occur on a gene", subtitle = "genes without SNPs not included")
ggsave("mutation-freq.png")
Sys.time()
