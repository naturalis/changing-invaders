#!/usr/bin/env Rscript
#SBATCH --job-name=filter-SNP
# filter SNPs
# by david
library(RSQLite)
library(dplyr, warn.conflicts = FALSE)
library(telegram)
if (!is.na(commandArgs(trailingOnly=TRUE)[1])) db = commandArgs(trailingOnly=TRUE)[1] else db = "/data/david.noteborn/acht.db"
Sys.time()
eightnucleotide <- dbConnect(SQLite(), db)
exulans <- tbl(eightnucleotide, "EXULANS")
zoekterm <- exulans %>% group_by(chromosome, position) %>% summarise(heterozygoot = !(n_distinct(paste0(GENOTYPE, "+", ALTERNATIVE)) == 1L && count(GENOTYPE) == 8L), p = COUNT(REFERENCE), COVERAGE_THRESHOLD = mean(COVERAGE, na.rm = TRUE) > 16L && 110L > mean(COVERAGE, na.rm = TRUE), QUALITY_THRESHOLD = mean(QUALITY, na.rm = TRUE) > 99L, DIST_P = min(ifelse(DIST_N==-1, 300, DIST_P), na.rm = TRUE), DIST_N = min(ifelse(DIST_N==-1, 300, DIST_N), na.rm = TRUE)) %>% filter(heterozygoot, COVERAGE_THRESHOLD, QUALITY_THRESHOLD, DIST_N > 299L, DIST_P > 299L)
# zoekterm <- zoekterm %>% ungroup() %>% summarise(hoeveel = count())
zoekterm <- zoekterm %>% select(chromosome, position)
zoekterm %>% show_query()
gefiltert <- zoekterm %>% collect()
dbDisconnect(eightnucleotide)
Sys.time()
bot <- TGBot$new(token = "TOKEN")
bericht <- paste("Er zijn", nrow(gefiltert), "SNPs over tijdens het verbeterde algoritme.")
bot$sendMessage(bericht, chat_id = 454771972)
cat(bericht)
write.csv(gefiltert, "filtered_improved.csv")
