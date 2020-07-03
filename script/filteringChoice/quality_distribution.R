#!/usr/bin/env Rscript
#SBATCH --job-name=distquality
# changing invaders
# make quality plot
# by david
# write.csv("depth1.csv")
# depth <- read.csv("depth1.csv", row.names = 1)
library(RSQLite)
library(dplyr, warn.conflicts = FALSE)
library(ggplot2)
Sys.time()
eightnucleotide <- dbConnect(SQLite(), Sys.glob("/d*/d*/eight.db"))
exulans <- tbl(eightnucleotide, "exulans")
# coverage, or QUALITY
# group on SNP, get the averga quality, (rounded on whole numbers) and look how much of a certain qualitly there are
searchterm <- exulans %>% group_by(chromosome, position) %>% summarise(quality = round(AVG(QUALITY))) %>% group_by(quality) %>% summarise(hoeveel = n())
searchterm %>% show_query()
quality <- searchterm %>% collect()
dbDisconnect(eightnucleotide)
# make a distribution plot of it
ggsave("quality.png", ggplot(quality, aes(quality, hoeveel)) + geom_col() + xlab("quality"))
Sys.time()
write.csv(quality, "quality.csv")
