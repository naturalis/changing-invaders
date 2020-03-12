#!/usr/bin/env Rscript
#SBATCH --job-name=filter-SNP
# filter SNPs
# by david
# biostrings is nodig (BiocManager::install("Biostrings"))
library(Biostrings)
library(RSQLite)
library(dplyr, warn.conflicts = FALSE)
library(telegram)
if (!is.na(commandArgs(trailingOnly=TRUE)[1])) db = commandArgs(trailingOnly=TRUE)[1] else db = "/data/david.noteborn/acht.db"
Sys.time()
eightnucleotide <- dbConnect(SQLite(), db)
exulans <- tbl(eightnucleotide, "EXULANS")
zoekterm <- exulans %>% group_by(chromosome, position) %>% summarise(heterozygoot = !(n_distinct(paste0(GENOTYPE_BP)) == 1L && count(GENOTYPE_BP) == 8L), p = COUNT(REFERENCE), COVERAGE_THRESHOLD = mean(COVERAGE, na.rm = TRUE) > 16L && 110L > mean(COVERAGE, na.rm = TRUE), QUALITY_THRESHOLD = mean(QUALITY, na.rm = TRUE) > 99L, DIST_P = min(ifelse(DIST_N==-1, 300, DIST_P), na.rm = TRUE), DIST_N = min(ifelse(DIST_N==-1, 300, DIST_N), na.rm = TRUE)) %>% filter(heterozygoot, COVERAGE_THRESHOLD, QUALITY_THRESHOLD, DIST_N > 249L, DIST_P > 249L)
# zoekterm <- zoekterm %>% ungroup() %>% summarise(hoeveel = count())
zoekterm <- zoekterm %>% select(chromosome, position)
zoekterm %>% show_query()
gefiltert <- zoekterm %>% collect()
dbDisconnect(eightnucleotide)
backup <- gefiltert
# lees het fasta basetand in.
# dit duurt wel even
s = readDNAStringSet(paste0(Sys.getenv("HOME"), "/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa"))
# bewerk de namen zodat het enkel het chromosoom nummer is
names(s) <- mapply(`[`, strsplit(names(s), " "), 1)
# gefiltert <- read.table("vanHIGHimpact.pos", col.names = c("chromosome", "position"))
gefiltert <- gefiltert[gefiltert$chromosome!=0,]
sequences <- apply(gefiltert, 1, function(x) {
  if (length(s[[x["chromosome"]]])>as.numeric(x["position"])+250&as.numeric(x["position"])-250>0)
    toString(subseq(s[[x["chromosome"]]], start=as.numeric(x["position"])-250, end = as.numeric(x["position"])+250)) else NA
})
# voeg sequenties toe aan positie tabel
gefiltert$voor <- substr(sequences, 1, 250)
gefiltert$na <- substr(sequences, 252, 501)
gefiltert$ref <- substr(sequences, 251, 251)
gefiltert <- gefiltert[!is.na(sequences),]
# sla op
setwd("/data/david.noteborn/blast_output")
write.csv(gefiltert, "filtered_snps.csv", quote = FALSE, row.names = FALSE)
# maak er een fasta van
system("sed -nE '1!{s/([0-9]+,[0-9]+),([^,]+),([^,]+),(.)/>\\1-\\4\\n\\2\\n>\\1-\\4\\n\\3/p}' filtered_snps.csv > filtered_snps.fasta")
Sys.time()
bot <- TGBot$new(token = "TOKEN")
bericht <- paste("Er zijn", nrow(gefiltert), "SNPs over tijdens het verbeterde algoritme.")
bot$sendMessage(bericht, chat_id = 0)
cat(bericht)
