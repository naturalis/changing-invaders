#!/usr/bin/env Rscript
#SBATCH --job-name=filter-SNP
# maak coverage plot
# by david
# write.csv("diepte1.csv")
# diepte <- read.csv("diepte1.csv", row.names = 1)
library(RSQLite)
library(dplyr, warn.conflicts = FALSE)
library(telegram)
library(ggplot2)
if (!is.na(commandArgs(trailingOnly=TRUE)[1])) db = commandArgs(trailingOnly=TRUE)[1] else db = "/data/david.noteborn/zeven_of_meer.db"
Sys.time()
sevennucleotide <- dbConnect(SQLite(), db)
exulans <- tbl(sevennucleotide, "EXULANS")
# zoekterm<-exulans %>% filter(DIST_N > 299L, DIST_P > 299L) %>% group_by(chromosome, position) %>% summarise(heterozygoot = !(n_distinct(GENOTYPE) == 1L && count(GENOTYPE) == 8L), p = COUNT(REFERENCE), COVERAGE_THRESHOLD = COVERAGE > 16L && 110L > COVERAGE, QUALITY_THESHOLD = QUALITY > 99L) %>% filter(heterozygoot, COVERAGE_THRESHOLD, QUALITY_THESHOLD) %>% summarise(v = count()) %>% summarise(v = sum(v))
zoekterm <- exulans %>% filter(DIST_N > 299L, DIST_P > 299L) %>% group_by(chromosome, position) %>% summarise(heterozygoot = !(n_distinct(GENOTYPE) == 1L && count(GENOTYPE) == 8L), p = COUNT(REFERENCE), COVERAGE_THRESHOLD = COVERAGE > 16L && 110L > COVERAGE, QUALITY_THESHOLD = QUALITY > 99L) %>% filter(heterozygoot, COVERAGE_THRESHOLD, QUALITY_THESHOLD) %>% select(chromosome, position)
zoekterm %>% show_query()
gefiltert <- zoekterm %>% collect()
dbDisconnect(sevennucleotide)
Sys.time()
bot <- TGBot$new(token = "939730741:AAHnRC-oDDSMJ_qjqmsxcrfcfWkJ6uaXm28")
bericht <- paste("Er zijn", nrow(gefiltert), "SNPs over")
bot$sendMessage(bericht, chat_id = 454771972)
cat(bericht)
write.csv(gefiltert, "filtered_snps.csv")
