#!/usr/bin/env Rscript
# get all positions witing genes and check whether they fall within exons
# then get all genes and explain how many mutations are really 'coding'
# changing invaders
# by david
library(future.apply, quietly = TRUE)
library(future.batchtools)
library(biomaRt)
library(ggplot2)
plan(batchtools_slurm, workers = 12)
Sys.time()
setwd("~/gen-ontologie/")
positions_with_mutations <- read.table("merge8_within_gene", header = FALSE, col.names=c("CHR", "POS"))
load("rnorvegicus-genen.RData")
genen_info <- genen_info[-grep("X|Y", genen_info$chromosome_name),]
genen_info$voor_position <- ifelse(genen_info$strand > 0, genen_info$start_position, genen_info$end_position)
genen_info$na_position   <- ifelse(genen_info$strand > 0, genen_info$end_position, genen_info$start_position)

# first we get all genes away that won't have a SNP anyway

gen_heeft_snp <- future_apply(genen_info, 1, function(gen) any(positions_with_mutations$CHR==gen["chromosome_name"]&gen["voor_position"]<=positions_with_mutations$POS&positions_with_mutations$POS<=gen["na_position"]))
table(gen_heeft_snp)
# next we  look what SNPs fall in exons
# for this we download the start and stop position of the exons
# the r. norvegicus database is used
ensembl = useDataset("rnorvegicus_gene_ensembl", mart = useMart("ensembl"))
genen_exon <- getBM(attributes = c('ensembl_gene_id', 'chromosome_name', 'exon_chrom_start', 'exon_chrom_end', 'ensembl_exon_id'),
                   filters = 'ensembl_gene_id',
                   values = genen_info[, "ensembl_gene_id"], #gene_has_snp
                   mart = ensembl)
save(file = "genen-exons.RData", genen_exon)
# all not exon positions are stored
niet_exon <- future_apply(positions_with_mutations, 1, function(chrpos) any(genen_exon$exon_chrom_start <= chrpos["POS"] & chrpos["POS"] <= genen_exon$exon_chrom_end & genen_exon$chromosome_name == chrpos["CHR"]))
table(niet_exon)
# all not exon mutations are removed
positions_within_exon <- positions_with_mutations[niet_exon,]
# next all genes are removed where not an mutation occurs in the exons
gen_binnen_exon_mutatie <- genen_info[future_apply(genen_info, 1, function(gen) any(positions_within_exon$CHR==gen["chromosome_name"]&gen["voor_position"]<=positions_within_exon$POS&positions_within_exon$POS<=gen["na_position"])),]
table(gen_binnen_exon_mutatie)
# how many mutations are then within the exons from a gene found
hoevaak_gen <- Reduce(rbind, future_apply(gen_binnen_exon_mutatie, 1, function(gen) data.frame(gen = gen["ensembl_gene_id"], hoevaak = sum(positions_within_exon$CHR==gen["chromosome_name"]&gen["voor_position"]<=positions_within_exon$POS&positions_within_exon$POS<=gen["na_position"]), stringsAsFactors = FALSE)))
write.table(hoevaak_gen, "hoevaakGenMetExon.csv", row.names = FALSE)
write.table(positions_within_exon, "mutatieBinnenExon.csv", row.names = FALSE)
table(hoevaak_gen$hoevaak)
# more than 85 mutations are displayed in a plot
vaak_voor <- hoevaak_gen[hoevaak_gen$hoevaak > 85,]
ggplot(vaak_voor, aes(gen, hoevaak)) + geom_col() + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + ggtitle("How many times there are SNPs", subtitle = "on the SNP richest genes")
ggsave("most-mutated.png")
# how many times a X time mutation occurs in this plot
ggplot(as.data.frame(table(hoevaak_gen$hoevaak)), aes(Var1, Freq)) + geom_col() + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + ggtitle("How many times does a X times SNPs occur on a gene", subtitle = "genes without SNPs not included")
ggsave("mutation-freq.png")
Sys.time()
