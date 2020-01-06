library(dplyr)
library(RSQLite)
# sla de gevalideerde posities (dmv tegen de consensus genomen te BLASTen) op
# bestand gemaakt dmv
# grep \> filtered_snps_P0041.fasta|uniq|sed '1{s/^>/"chromosome","position"\n/};s/^>//;s/..$//' > ../filtered_snps_valid_first_round.csv
posities <- read.csv("/data/david.noteborn/filtered_snps_valid_first_round.csv")
if (!is.na(commandArgs(trailingOnly=TRUE)[1])) db = commandArgs(trailingOnly=TRUE)[1] else db = "/data/david.noteborn/zeven_of_meer.db"
eightnucleotide <- dbConnect(SQLite(), db)
dbWriteTable(eightnucleotide, "FILTERED_VALIDATE_FR", posities, overwrite = TRUE)
dbListTables(eightnucleotide)

exulans <- tbl(eightnucleotide, 'EXULANS')
filtered_snps <- tbl(eightnucleotide, 'FILTERED_VALIDATE_FR')

dbDisconnect(eightnucleotide)
