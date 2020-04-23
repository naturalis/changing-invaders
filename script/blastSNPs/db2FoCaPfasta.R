#!/usr/bin/env Rscript
#SBATCH --job-name=unique-SNP
# changing invaders
# unique more
# by david
# biostrings is nodig (BiocManager::install("Biostrings"))
library(Biostrings)
library(RSQLite)
library(dplyr, warn.conflicts = FALSE)
library(telegram)
if (!is.na(commandArgs(trailingOnly=TRUE)[1])) db = commandArgs(trailingOnly=TRUE)[1] else db = "/data/david.noteborn/eight.db"
Sys.time()
eightnucleotide <- dbConnect(SQLite(), db)
exulans <- tbl(eightnucleotide, "EXULANS")
# group on SNP, make a variable that explains whether it is a heterozygote SNP, and whether the coverage, quality and distance comply
# filter on these variables
searchterm <- exulans %>% group_by(chromosome, position) %>% summarise(heterozygote = !(n_distinct(paste0(GENOTYPE_BP)) == 1L && count(GENOTYPE_BP) == 8L), p = COUNT(REFERENCE), COVERAGE_THRESHOLD = mean(COVERAGE, na.rm = TRUE) > 16L && 110L > mean(COVERAGE, na.rm = TRUE), QUALITY_THRESHOLD = mean(QUALITY, na.rm = TRUE) > 99L, DIST_P = min(ifelse(DIST_N==-1, 250, DIST_P), na.rm = TRUE), DIST_N = min(ifelse(DIST_N==-1, 250, DIST_N), na.rm = TRUE)) %>% filter(heterozygote, COVERAGE_THRESHOLD, QUALITY_THRESHOLD, DIST_N > 249L, DIST_P > 249L)
# searchterm <- searchterm %>% ungroup() %>% summarise(how_many = count())
searchterm <- searchterm %>% select(chromosome, position)
searchterm %>% show_query()
filtered <- searchterm %>% collect()
dbDisconnect(eightnucleotide)
# read the reference fasta file in.
# this takes some time
DNA_sequences = readDNAStringSet(paste0(Sys.getenv("HOME"), "/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa"))
# edit the names so it is only the chromosome number
names(DNA_sequences) <- mapply(`[`, strsplit(names(DNA_sequences), " "), 1)
# filtered <- read.table("vanHIGHimpact.pos", col.names = c("chromosome", "position"))
filtered <- filtered[filtered$chromosome!=0,]
sequences <- apply(filtered, 1, function(x) {
  # check whether flanking regions are on the chromosome to stop errors
  if (length(DNA_sequences[[x["chromosome"]]])>as.numeric(x["position"])+250&as.numeric(x["position"])-250>0)
    # if that applies, get 250 before, to 250 after the SNP
    toString(subseq(DNA_sequences[[x["chromosome"]]], start=as.numeric(x["position"])-250, end = as.numeric(x["position"])+250)) else NA
})
# add sequences to the position table
filtered$before <- substr(sequences, 1, 250)
filtered$after <- substr(sequences, 252, 501)
filtered$ref <- substr(sequences, 251, 251)
filtered <- filtered[!is.na(sequences),]
# store it
setwd("/data/david.noteborn/blast_output")
write.csv(filtered, "filtered_snps.csv", quote = FALSE, row.names = FALSE)
# make it a fasta
# the csv file looks like this:
# CHR,POS,seq_before,seq_after,SNP_base
# the first line is a header, that is skipped (1! in combination with -n, which explains that not everything is written by default to stdout)
# next it is converted to this format:
# >CHR,POS-base
# seq_before
# >CHR,POS-base
# seq_after
# this is done by groupregex catch and replace
# the p in the end explains that this should be written to stdout
# -E explains that this is about an extended regular expression which gives us the advantage to not write
# all groups like \(content\) but like (content) and use + (1 or more instead of * 0 or more)
system("sed -nE '1!{s/([0-9]+,[0-9]+),([^,]+),([^,]+),(.)/>\\1-\\4\\n\\2\\n>\\1-\\4\\n\\3/p}' filtered_snps.csv > filtered_snps.fasta")
Sys.time()
# append here the telegram bot token one wants to use during this analysis
bot <- TGBot$new(token = "TOKEN")
SNP_message <- paste("There are", nrow(filtered), "SNPs left during the improved algorithm.")
bot$sendMessage(SNP_message, chat_id = 0)
cat(SNP_message)
