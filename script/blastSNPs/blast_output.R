#!/usr/bin/env Rscript
# changing invaders
# by david
suppressMessages(library(Biostrings, quietly = TRUE))
library(jsonlite)
setwd(Sys.glob("/data/d*.n*"))
sample <- commandArgs(TRUE)[1]
if (is.na(sample)) sample <- "blast_output/filtered_R6750"
remove_this <- function(json_list, bool_vector) json_list[-grep(paste0(sub(" .*", "", names(json_list)[bool_vector]), collapse = "|"), names(json_list))]
json_combination <- Map(function(x) fromJSON(x, simplifyVector = FALSE)$BlastOutput2, rev(rev(gsub("$", "\n}\n", unlist(strsplit(paste0(readLines(paste0(sample, ".json")), collapse = "\n"), "\n}\n"))))[-1]))
names(json_combination) <- paste(unlist(Map(function(x)x$report$results$search$query_title, json_combination, USE.NAMES = FALSE)), c("before", "after"))
how_many_hits <- unlist(Map(function(x)length(x$report$results$search$hits)==1&&length(x$report$results$search$hits[[1]]$hsps)==1, json_combination, USE.NAMES = FALSE))
# table(how_many_hits)
json_combination <- remove_this(json_combination, !how_many_hits)
contains_gap <- mapply(function(x) {
  hit <- x$report$results$search$hits[[1]]$hsps[[1]]
  grepl("-", hit$qseq)|grepl("-", hit$hseq)
}, json_combination)
# table(contains_gap)
json_combination <- remove_this(json_combination, contains_gap)
pos_pairs <- sub(" .*", "", names(json_combination))
pos_pairs <- pos_pairs[!duplicated(pos_pairs)]
dna <- readDNAStringSet(paste0(sample, ".fasta"))
dna_filter <- dna[grep(paste(pos_pairs, collapse = "|"), names(dna))]
writeXStringSet(dna_filter, paste0(sample, ".fasta"), width = 300)
## how_much_after <- nchar(sub("^([^-]+)-.*", "\\1", alignment$hseq))
## how_much_before <- nchar(sub(".*-([^-]+)$", "\\1", alignment$hseq))
