#!/usr/bin/env Rscript
#SBATCH --job-name=n-SNP
# changing invaders
# naturalis
# filter SNPs
# by david
library(RSQLite)
library(dplyr, warn.conflicts = FALSE)
library(telegram)
if (!is.na(commandArgs(trailingOnly=TRUE)[1])) db = commandArgs(trailingOnly=TRUE)[1] else db = Sys.glob("/d*/d*/eight.db")
Sys.time()
eightnucleotide <- dbConnect(SQLite(), db)
exulans <- tbl(eightnucleotide, "EXULANS")
searchterm <- exulans %>% group_by(chromosome, position) %>%
 summarise(p = COUNT(REFERENCE),
  COVERAGE_THRESHOLD = mean(COVERAGE, na.rm = TRUE) > 16L && 110L > mean(COVERAGE, na.rm = TRUE),
  QUALITY_THRESHOLD = mean(QUALITY, na.rm = TRUE) > 99L) %>%
 filter(COVERAGE_THRESHOLD, QUALITY_THRESHOLD) %>%
 ungroup() %>% summarise(hoeveel = count())
searchterm %>% show_query()
filtered <- searchterm %>% collect()
# 80468536
# within 8 combined
# 90532094
# filter on quality
# 83693196
# filter on both
# 17608592
dbDisconnect(eightnucleotide)
eight_combined <- dbConnect(SQLite(), Sys.glob("/h*/r*.v*/f*/p*/B1900*/S*/onenucleotide_acht.db"))
exulans <- tbl(eight_combined, "EXULANS")
searchterm <- exulans %>% filter(QUAL > 99L) %>% summarise(amount = count())
searchterm %>% collect()
dbDisconnect(eight_combined)

Sys.time()
# bot <- TGBot$new(token = "TOKEN")
message <- paste("There are", nrow(filtered), "SNPs remaining")
# bot$sendMessage(message, chat_id = 0)
cat(message)
write.csv(filtered, "filtered_snps.csv")
