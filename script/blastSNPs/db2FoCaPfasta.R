#!/usr/bin/env Rscript
#SBATCH --job-name=unique-SNP
# changing invaders
# by david
# obtain FoCaP + distance SNP upstream + downstream sequences from R norvegicus
suppressMessages(library(Biostrings))
library(RSQLite)
library(dplyr, warn.conflicts = FALSE)
library(telegram)
# this is a shortcut operator for either using a default value or using the value of a environment variable
"%andfordefault%" <- function(env_var, default) ifelse(is.na(Sys.getenv(env_var)), default, Sys.getenv(env_var))
if (!is.na(commandArgs(trailingOnly=TRUE)[1])) db = commandArgs(trailingOnly=TRUE)[1] else db = Sys.glob("/d*/d*/eight.db")
Sys.time()
eightnucleotide <- dbConnect(SQLite(), db)
exulans <- tbl(eightnucleotide, "EXULANS")
# group on SNP, make a variable that explains whether it is a heterozygote SNP, and whether the coverage, quality and distance comply
# filter on these variables
coverage_min <- as.integer("COVERAGE_MIN" %andfordefault% 16L)
coverage_max <- as.integer("COVERAGE_MAX" %andfordefault% 110L)
quality_minima <- as.integer("QUALITY" %andfordefault% 99L)
distance_min <- as.integer("DISTANCE" %andfordefault% 250L)
searchterm <- exulans %>% group_by(chromosome, position) %>%
 summarise(heterozygote = !(n_distinct(paste0(GENOTYPE_BP)) == 1L && count(GENOTYPE_BP) == 8L),
  p = COUNT(REFERENCE),
  COVERAGE_THRESHOLD = mean(COVERAGE, na.rm = TRUE) > coverage_min && coverage_max > mean(COVERAGE, na.rm = TRUE),
  QUALITY_THRESHOLD = mean(QUALITY, na.rm = TRUE) > quality_minima,
  DIST_P = min(ifelse(DIST_N==-1, distance_min, DIST_P), na.rm = TRUE),
  DIST_N = min(ifelse(DIST_N==-1, distance_min, DIST_N), na.rm = TRUE)) %>%
 filter(heterozygote, COVERAGE_THRESHOLD, QUALITY_THRESHOLD, DIST_N > (distance_min - 1L), DIST_P > (distance_min - 1L))
# searchterm <- searchterm %>% ungroup() %>% summarise(how_many = count())
searchterm <- searchterm %>% select(chromosome, position)
searchterm %>% show_query()
filtered <- searchterm %>% collect()
dbWriteTable(eightnucleotide, "FOCAP", filtered, overwrite = TRUE)
write.csv(filtered, "data/FOCAP.csv", row.names = FALSE)

dbDisconnect(eightnucleotide)
# read the reference fasta file in.
# this takes some time
reference = ifelse(is.na(Sys.getenv()["REF"]), paste0(Sys.getenv("HOME"), "/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa"), Sys.getenv()["REF"])
DNA_sequences = readDNAStringSet(reference)
# edit the names so it is only the chromosome number
names(DNA_sequences) <- mapply(`[`, strsplit(names(DNA_sequences), " "), 1)
# filtered <- read.table("vanHIGHimpact.pos", col.names = c("chromosome", "position"))
filtered <- filtered[filtered$chromosome!=0,]
if (nrow(filtered)==0) {
	message("There has been no SNPs that comply the filterin criterion set, maybe try again with other filtering parameters")
	quit(save="no")
}
sequences <- apply(filtered, 1, function(x) {
  # check whether flanking regions are on the chromosome to stop errors
  if (length(DNA_sequences[[as.character(x["chromosome"])]])>as.numeric(x["position"])+250&as.numeric(x["position"])-250>0)
    # if that applies, get 250 before, to 250 after the SNP
    toString(subseq(DNA_sequences[[as.character(x["chromosome"])]], start=as.numeric(x["position"])-250, end = as.numeric(x["position"])+250)) else NA
})
# add sequences to the position table
filtered$before <- substr(sequences, 1, 250)
filtered$after <- substr(sequences, 252, 501)
filtered$ref <- substr(sequences, 251, 251)
filtered <- filtered[!is.na(sequences),]
# store it
write.csv(filtered, "data/filtered_snps.csv", quote = FALSE, row.names = FALSE)
# make it a fasta
# the csv file looks like this:
# CHR,POS,seq_before,seq_after,SNP_base
# the first line is a header, that is skipped (1! in combination with -n, which explains that not everything is written by default to stdout)
# next it is converted to this format:
# >CHR,POS-base
# seq_before
# >CHR,POS-base
# seq_after
# this is done by groupregex catch and replace
# the p in the end explains that this should be written to stdout
# -E explains that this is about an extended regular expression which gives us the advantage to not write
# all groups like \(content\) but like (content) and use + (1 or more instead of * 0 or more)
system("sed -nE '1!{s/([0-9]+,[0-9]+),([^,]+),([^,]+),(.)/>\\1-\\4\\n\\2\\n>\\1-\\4\\n\\3/p}' data/filtered_snps.csv > data/filtered_snps.fasta")
Sys.time()
SNP_message <- paste("There are", nrow(filtered), "SNPs left during the improved algorithm.")
# append here the telegram bot token one wants to use during this analysis
##  bot <- TGBot$new(token = "TOKEN")
##  bot$sendMessage(SNP_message, chat_id = 0)
cat(SNP_message)
