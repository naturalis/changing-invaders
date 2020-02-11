suppressMessages(library(Biostrings, quietly = TRUE))
library(jsonlite)
setwd("/data/david.noteborn")
sample <- commandArgs(TRUE)[1]
if (is.na(sample)) sample <- "blast_output/filtered_R6750"
haal_weg <- function(lijst, boolvector) lijst[-grep(paste0(sub(" .*", "", names(lijst)[boolvector]), collapse = "|"), names(lijst))]
jsoncomb <- Map(function(x) fromJSON(x, simplifyVector = FALSE)$BlastOutput2, rev(rev(gsub("$", "\n}\n", unlist(strsplit(paste0(readLines(paste0(sample, ".json")), collapse = "\n"), "\n}\n"))))[-1]))
names(jsoncomb) <- paste(unlist(Map(function(x)x$report$results$search$query_title, jsoncomb, USE.NAMES = FALSE)), c("voor", "na"))
hoeveelhits <- unlist(Map(function(x)length(x$report$results$search$hits)==1&&length(x$report$results$search$hits[[1]]$hsps)==1, jsoncomb, USE.NAMES = FALSE))
# table(hoeveelhits)
jsoncomb <- haal_weg(jsoncomb, !hoeveelhits)
bezitgap <- mapply(function(x) {
  hit <- x$report$results$search$hits[[1]]$hsps[[1]]
  grepl("-", hit$qseq)|grepl("-", hit$hseq)
}, jsoncomb)
# table(bezitgap)
jsoncomb <- haal_weg(jsoncomb, bezitgap)
pospairs <- sub(" .*", "", names(jsoncomb))
pospairs <- pospairs[!duplicated(pospairs)]
dna <- readDNAStringSet(paste0(sample, ".fasta"))
dna_filter <- dna[grep(paste(pospairs, collapse = "|"), names(dna))]
writeXStringSet(dna_filter, paste0(sample, ".fasta"), width = 300)
#nietkwartk <- unlist(Map(function(x) {
#  alignment <- x$report$results$search$hits[[1]]$hsps[[1]]
#  (nchar(alignment$hseq[1])==250)[1]
#},
#jsoncomb, USE.NAMES = FALSE
#))
## hoeveel_na <- nchar(sub("^([^-]+)-.*", "\\1", alignment$hseq))
## hoeveel_voor <- nchar(sub(".*-([^-]+)$", "\\1", alignment$hseq))
