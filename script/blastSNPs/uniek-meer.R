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
if (!is.na(commandArgs(trailingOnly=TRUE)[1])) db = commandArgs(trailingOnly=TRUE)[1] else db = "/data/david.noteborn/acht.db"
Sys.time()
eightnucleotide <- dbConnect(SQLite(), db)
exulans <- tbl(eightnucleotide, "EXULANS")
# group on SNP, make a variable that explains whether it is a heterozygote SNP, and whether the coverage, quality and distance comply
# filter on these variables
zoekterm <- exulans %>% group_by(chromosome, position) %>% summarise(heterozygoot = !(n_distinct(paste0(GENOTYPE_BP)) == 1L && count(GENOTYPE_BP) == 8L), p = COUNT(REFERENCE), COVERAGE_THRESHOLD = mean(COVERAGE, na.rm = TRUE) > 16L && 110L > mean(COVERAGE, na.rm = TRUE), QUALITY_THRESHOLD = mean(QUALITY, na.rm = TRUE) > 99L, DIST_P = min(ifelse(DIST_N==-1, 250, DIST_P), na.rm = TRUE), DIST_N = min(ifelse(DIST_N==-1, 250, DIST_N), na.rm = TRUE)) %>% filter(heterozygoot, COVERAGE_THRESHOLD, QUALITY_THRESHOLD, DIST_N > 249L, DIST_P > 249L)
# zoekterm <- zoekterm %>% ungroup() %>% summarise(hoeveel = count())
zoekterm <- zoekterm %>% select(chromosome, position)
zoekterm %>% show_query()
gefiltert <- zoekterm %>% collect()
dbDisconnect(eightnucleotide)
backup <- gefiltert
# read the reference fasta file in.
# this takes some time
s = readDNAStringSet(paste0(Sys.getenv("HOME"), "/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa"))
# edit the names so it is only the chromosome number
names(s) <- mapply(`[`, strsplit(names(s), " "), 1)
# gefiltert <- read.table("vanHIGHimpact.pos", col.names = c("chromosome", "position"))
gefiltert <- gefiltert[gefiltert$chromosome!=0,]
sequences <- apply(gefiltert, 1, function(x) {
  # check whether flanking regions are on the chromosome to stop errors
  if (length(s[[x["chromosome"]]])>as.numeric(x["position"])+250&as.numeric(x["position"])-250>0)
    # if that applies, get 250 before, to 250 after the SNP
    toString(subseq(s[[x["chromosome"]]], start=as.numeric(x["position"])-250, end = as.numeric(x["position"])+250)) else NA
})
# add sequences to the position table
gefiltert$voor <- substr(sequences, 1, 250)
gefiltert$na <- substr(sequences, 252, 501)
gefiltert$ref <- substr(sequences, 251, 251)
gefiltert <- gefiltert[!is.na(sequences),]
# store it
setwd("/data/david.noteborn/blast_output")
write.csv(gefiltert, "filtered_snps.csv", quote = FALSE, row.names = FALSE)
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
bericht <- paste("There are", nrow(gefiltert), "SNPs left during the improved algorithm.")
bot$sendMessage(bericht, chat_id = 0)
cat(bericht)
