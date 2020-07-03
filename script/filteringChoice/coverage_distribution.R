#!/usr/bin/env Rscript
#SBATCH --job-name=distquality
# changing invaders
# by david
# make coverage plot
# write.csv("depth1.csv")
# depth <- read.csv("depth1.csv", row.names = 1)
library(RSQLite)
library(dplyr, warn.conflicts = FALSE)
library(telegram)
library(ggplot2)
Sys.time()
eightnucleotide <- dbConnect(SQLite(), Sys.glob("/d*/d*/eight.db"))
exulans <- tbl(eightnucleotide, "EXULANS")
# coverage, or QUALITY
if (FALSE)
  searchterm <- exulans %>% group_by(chromosome, position) %>% summarise(cov = round(AVG(COVERAGE))) %>% group_by(cov) %>% summarise(amount = n()) else
  # group on SNP, summarise coverage, check how much that (amount of) coverage occurs
  searchterm <- exulans %>% group_by(chromosome, position) %>% summarise(cov = SUM(COVERAGE)) %>% group_by(cov) %>% summarise(amount = n())
searchterm %>% show_query()
depth <- searchterm %>% collect()
dbDisconnect(eightnucleotide)
# make a distribution plot from it
ggsave("coverage.png", ggplot(depth, aes(cov, amount)) + geom_col() + xlab("depth (totaal per positie)"))
write.csv(depth, "coverage.csv")
