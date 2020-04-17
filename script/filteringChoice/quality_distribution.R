#!/usr/bin/env Rscript
#SBATCH --job-name=distkwaliteit
# changing invaders
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
exulans <- tbl(eightnucleotide, "exulans")
# coverage, or QUALITY
# group on SNP, get the averga quality, (rounded on whole numbers) and look how much of a certain qualitly there are
zoekterm <- exulans %>% group_by(chromosome, position) %>% summarise(qual = round(AVG(QUALITY))) %>% group_by(qual) %>% summarise(hoeveel = n())
zoekterm %>% show_query()
kwaliteit <- zoekterm %>% collect()
dbDisconnect(eightnucleotide)
# make a distribution plot of it
ggsave("kwaliteit.png", ggplot(kwaliteit, aes(qual, hoeveel)) + geom_col() + xlab("kwaliteit"))
Sys.time()
write.csv(kwaliteit, "kwaliteit.csv")
