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
eightnucleotide <- dbConnect(SQLite(), "/data/david.noteborn/acht.db")
exulans <- tbl(eightnucleotide, "exulans")
# coverage, of QUALITY
zoekterm <- exulans %>% group_by(chromosome, position) %>% summarise(qual = round(AVG(QUALITY))) %>% group_by(qual) %>% summarise(hoeveel = n())
zoekterm %>% show_query()
kwaliteit <- zoekterm %>% collect()
dbDisconnect(eightnucleotide)
ggsave("kwaliteit.png", ggplot(kwaliteit, aes(qual, hoeveel)) + geom_col() + xlab("kwaliteit"))
Sys.time()
write.csv(kwaliteit, "kwaliteit.csv")
