#!/usr/bin/env Rscript
# get all positions within a gene of R. Norvegicus
# changing invaders
# by david
# example invocation:
# bcftools view merge8.bcf |Rscript binneneengen.R > merge8_within_gene
standard_input <- file("stdin")
open(standard_input, blocking=TRUE)
library(biomaRt)
genes <- AnnotationDbi::keys(org.Rn.eg.db::org.Rn.eg.db, "ENSEMBL")
ensembl <- useMart("ensembl")
# get the r. norvegicus database
ensembl = useDataset("rnorvegicus_gene_ensembl", mart = ensembl)
# download for all genes the start, stop position, chromosome name strand and describtion
genes_info <- getBM(attributes = c('chromosome_name', 'start_position', 'end_position', "strand", 'description', 'ensembl_gene_id'), # 'exon_chrom_start', 'exon_chrom_end',
                    filters = 'ensembl_gene_id',
                    values = genes,
                    mart = ensembl)
save(genes_info, file = "rnorvegicus-genes.RData", version = 2)
genes_info <- genes_info[-grep("X|Y", genes_info$chromosome_name),]
genes_info$before_position <- ifelse(genes_info$strand > 0, genes_info$start_position, genes_info$end_position)
genes_info$after_position   <- ifelse(genes_info$strand > 0, genes_info$end_position, genes_info$start_position)


while(length(line <- readLines(standard_input,n=1)) > 0)
  if (!startsWith(line, "#")) {
    chr_pos <- unlist(strsplit(line, "\t"))[1:2]
    hits <- with(genes_info, genes_info[chromosome_name==chr_pos[1] & before_position >= as.numeric(chr_pos[2]) & as.numeric(chr_pos[2]) >= after_position,])
    # if there is a hit, print it to the standard output
    if (nrow(hits)!=0) write(paste0(chr_pos, collapse = "\t"), stdout())
  }
