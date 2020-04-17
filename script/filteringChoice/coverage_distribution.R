#!/usr/bin/env Rscript
# changing invaders
#SBATCH --job-name=distquality
# make coverage plot
# by david
# write.csv("diepte1.csv")
# diepte <- read.csv("diepte1.csv", row.names = 1)
library(RSQLite)
library(dplyr, warn.conflicts = FALSE)
library(telegram)
library(ggplot2)
Sys.time()
eightnucleotide <- dbConnect(SQLite(), "/data/david.noteborn/acht.db")
exulans <- tbl(eightnucleotide, "EXULANS")
# coverage, or QUALITY
if (FALSE)
  zoekterm <- exulans %>% group_by(chromosome, position) %>% summarise(cov = round(AVG(COVERAGE))) %>% group_by(cov) %>% summarise(hoeveel = n()) else
  # group on SNP, summarise coverage, check how much that coverage occurs
  zoekterm <- exulans %>% group_by(chromosome, position) %>% summarise(cov = SUM(COVERAGE)) %>% group_by(cov) %>% summarise(hoeveel = n())
zoekterm %>% show_query()
diepte <- zoekterm %>% collect()
dbDisconnect(eightnucleotide)
# make a distribution plot from it
ggsave("coverage.png", ggplot(diepte, aes(cov, hoeveel)) + geom_col() + xlab("diepte (totaal per positie)"))
write.csv(diepte, "coverage.csv")
