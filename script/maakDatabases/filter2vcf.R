library(dplyr)
library(RSQLite)
posities <- read.csv("posities.csv", row.names = 1)
if (!is.na(commandArgs(trailingOnly=TRUE)[1])) db = commandArgs(trailingOnly=TRUE)[1] else db = "/data/david.noteborn/zeven_of_meer.db"
eightnucleotide <- dbConnect(SQLite(), db)
dbWriteTable(eightnucleotide, "FILTERED", posities, overwrite = TRUE)
dbListTables(eightnucleotide)

exulans <- tbl(eightnucleotide, 'EXULANS')
filtered_snps <- tbl(eightnucleotide, 'FILTERED')

zoekterm <- semi_join(exulans, filtered_snps, by = c("POSITION" = "position", "CHROMOSOME" = "chromosome"))

zoekterm %>% show_query()
gefilterd <- zoekterm %>% collect()

dbDisconnect(eightnucleotide)
