library(dplyr)
library(RSQLite)
library(Biostrings)
# sla de gevalideerde posities (dmv tegen de consensus genomen te BLASTen) op
# neem het laatste fasta bestand
setwd("/data/david.noteborn/blast_output/")
blasted <- file.info(paste0(list.files(pattern = "fasta")))
fasta.bestand <- rownames(blasted[with(blasted, order(mtime, decreasing = TRUE)), ][1,])
chrpos <- strsplit(sub("..$", "", unique(names(readDNAStringSet(fasta.bestand)))), ",")
posities <- data.frame(chromosome = as.numeric(mapply(`[`, chrpos, 1)),
                       position = as.numeric(mapply(`[`, chrpos, 2)))
# system('grep \\> filtered_snps_P0041.fasta|uniq|sed \'1{s/^>/"chromosome","position"\\n/};s/^>//;s/..$//\' > ../filtered_snps_valid_first_round.csv')
# posities <- read.csv("/data/david.noteborn/filtered_snps_valid_first_round.csv")
if (!is.na(commandArgs(trailingOnly=TRUE)[1])) db = commandArgs(trailingOnly=TRUE)[1] else db = "/data/david.noteborn/acht.db"
eightnucleotide <- dbConnect(SQLite(), db)
dbWriteTable(eightnucleotide, "FILTERED_VALIDATE_FR", posities, overwrite = TRUE)
dbListTables(eightnucleotide)
dbExecute(eightnucleotide, "CREATE TABLE IF NOT EXISTS EXULANS_VALID AS SELECT * FROM EXULANS INNER JOIN FILTERED_VALIDATE_FR ON EXULANS.POSITION = FILTERED_VALIDATE_FR.position AND EXULANS.CHROMOSOME = FILTERED_VALIDATE_FR.chromosome;")
# filtered_snps <- tbl(eightnucleotide, 'FILTERED_VALIDATE_FR')
dbDisconnect(eightnucleotide)
