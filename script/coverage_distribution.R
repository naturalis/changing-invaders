#!/usr/bin/env Rscript
#SBATCH --job-name=distkwaliteit
# maak coverage plot
# by david
# write.csv("diepte1.csv")
# diepte <- read.csv("diepte1.csv", row.names = 1)
library(RSQLite)
library(dplyr, warn.conflicts = FALSE)
library(telegram)
library(ggplot2)
Sys.time()
sevennucleotide <- dbConnect(SQLite(), "/data/david.noteborn/zeven_of_meer.db")
exulans <- tbl(sevennucleotide, "EXULANS")
# coverage, of QUALITY
if (FALSE)
  zoekterm <- exulans %>% group_by(chromosome, position) %>% summarise(cov = round(AVG(COVERAGE))) %>% group_by(cov) %>% summarise(hoeveel = n()) else
  zoekterm <- exulans %>% group_by(chromosome, position) %>% summarise(cov = SUM(COVERAGE)) %>% group_by(cov) %>% summarise(hoeveel = n())
zoekterm %>% show_query()
diepte <- zoekterm %>% collect()
dbDisconnect(sevennucleotide)
ggsave("coverage.png", ggplot(diepte, aes(cov, hoeveel)) + geom_col() + xlab("diepte (totaal per positie)"))
write.csv(diepte, "coverage.csv")
