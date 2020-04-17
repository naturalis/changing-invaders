#!/usr/bin/env Rscript
# get all positions withing a gene of R. Norvegicus
# changing invaders
# by david
# example invocation:
# bcftools view merge8.bcf |Rscript binneneengen.R > merge8_within_gene
f <- file("stdin")
open(f, blocking=TRUE)
genes <- AnnotationDbi::keys(org.Rn.eg.db::org.Rn.eg.db, "ENSEMBL")
ensembl <- useMart("ensembl")
# get the r. norvegicus database
ensembl = useDataset("rnorvegicus_gene_ensembl", mart = ensembl)
# download for all genes the start, stop position, chromosome name strand and describtion
genen_info <- getBM(attributes = c('chromosome_name', 'start_position', 'end_position', "strand", 'description', 'ensembl_gene_id'), # 'exon_chrom_start', 'exon_chrom_end',
                    filters = 'ensembl_gene_id',
                    values = genes,
                    mart = ensembl)
save(genen_info, file = "rnorvegicus-genen.RData", version = 2)
genen_info <- genen_info[-grep("X|Y", genen_info$chromosome_name),]
genen_info$voor_position <- ifelse(genen_info$strand > 0, genen_info$start_position, genen_info$end_position)
genen_info$na_position   <- ifelse(genen_info$strand > 0, genen_info$end_position, genen_info$start_position)


while(length(line <- readLines(f,n=1)) > 0)
  if (!startsWith(line, "#")) {
    chrpos <- unlist(strsplit(line, "\t"))[1:2]
    hits <- with(genen_info, genen_info[chromosome_name==chrpos[1] & voor_position >= as.numeric(chrpos[2]) & as.numeric(chrpos[2]) >= na_position,])
    # if there is a hit, print it to the standard output
    if (nrow(hits)!=0) write(paste0(chrpos, collapse = "\t"), stdout())
  }
