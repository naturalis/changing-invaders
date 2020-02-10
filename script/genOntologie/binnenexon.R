#!/usr/bin/env Rscript
# neem alle posities binnen een genen en kijk of ze binnen de exonen vallen
# neem vervolgens alle genen en geef aan hoeveel mutaties nou echt 'coderend' zijn
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

# eerst halen we alle genen weg waar sowieso geen genen in voorkomen

gen_heeft_snp <- future_apply(genen_info, 1, function(gen) any(positions_with_mutations$CHR==gen["chromosome_name"]&gen["voor_position"]<=positions_with_mutations$POS&positions_with_mutations$POS<=gen["na_position"]))
table(gen_heeft_snp)
# vervolgens kijkwen we welke SNPs binnen exonen vallen
# hiervoor downloaden we de start en stop positie van de exonen
# de r. norvegicus database is gebruikt
ensembl = useDataset("rnorvegicus_gene_ensembl", mart = useMart("ensembl"))
genen_exon <- getBM(attributes = c('ensembl_gene_id', 'chromosome_name', 'exon_chrom_start', 'exon_chrom_end', 'ensembl_exon_id'),
                   filters = 'ensembl_gene_id',
                   values = genen_info[, "ensembl_gene_id"], #gen_heeft_snp
                   mart = ensembl)
save(file = "genen-exons.RData", genen_exon)
# alle niet exon posities worden opgeslagen
niet_exon <- future_apply(positions_with_mutations, 1, function(chrpos) any(genen_exon$exon_chrom_start <= chrpos["POS"] & chrpos["POS"] <= genen_exon$exon_chrom_end & genen_exon$chromosome_name == chrpos["CHR"]))
table(niet_exon)
# alle niet exon mutatie worden weggehaald
positions_within_exon <- positions_with_mutations[niet_exon,]
# vervolgens halen we alle genen weg waarbij er geeen mutatie is voorgekomen in de exonen
gen_binnen_exon_mutatie <- genen_info[future_apply(genen_info, 1, function(gen) any(positions_within_exon$CHR==gen["chromosome_name"]&gen["voor_position"]<=positions_within_exon$POS&positions_within_exon$POS<=gen["na_position"])),]
table(gen_binnen_exon_mutatie)
# hoeveel mutaties zijn vervolgens binnen de exonen van een gen gevonden
hoevaak_gen <- Reduce(rbind, future_apply(gen_binnen_exon_mutatie, 1, function(gen) data.frame(gen = gen["ensembl_gene_id"], hoevaak = sum(positions_within_exon$CHR==gen["chromosome_name"]&gen["voor_position"]<=positions_within_exon$POS&positions_within_exon$POS<=gen["na_position"]), stringsAsFactors = FALSE)))
write.table(hoevaak_gen, "hoevaakGenMetExon.csv", row.names = FALSE)
write.table(positions_within_exon, "mutatieBinnenExon.csv", row.names = FALSE)
table(hoevaak_gen$hoevaak)
# meer dan 85 mutaties worden weergegeven in een plot
vaak_voor <- hoevaak_gen[hoevaak_gen$hoevaak > 85,]
ggplot(vaak_voor, aes(gen, hoevaak)) + geom_col() + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + ggtitle("Hoe vaak komen er SNPs voor", subtitle = "op de SNP rijkste genen")
ggsave("meest-gemuteerd.png")
# hoe vaak een X aantal mutaties voor komt wordt weergeven in deze plot
ggplot(as.data.frame(table(hoevaak_gen$hoevaak)), aes(Var1, Freq)) + geom_col() + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + ggtitle("Hoe vaak komen er een X aantal SNPs op een gen voor", subtitle = "genen zonden SNPs niet meegenomen")
ggsave("mutatie-freq.png")
Sys.time()
