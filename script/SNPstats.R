#!/usr/bin/env Rscript
#SBATCH --job-name=SNPfinal
# extract SNPs (last step)
# by david
# changing invaders
library(RSQLite)
library(dplyr, warn.conflicts = FALSE)
library(telegram)
library(ggplot2)
library(Biostrings)
removeNearest <- function(distance, remain = 100) {
  # longing == all taken SNPs
  # notYet == rest
  # while more SNPs should be added, calculate the minimal distance of every in rest related to all
  # longing. Is that distance maxed, add to longing
  longing <- distance %>% arrange(CHROMOSOME, POSITION) %>% group_by(CHROMOSOME) %>% filter(row_number() == 1 | row_number() == n())
  notYet <- distance %>% arrange(CHROMOSOME, POSITION) %>% group_by(CHROMOSOME) %>% filter(!(row_number() == 1 | row_number() == n()))
  
  while (nrow(longing) != remain & nrow(notYet) != 0) {
    q <- apply(notYet, 1, function(x) {
      chrw <- longing[longing$CHROMOSOME == as.numeric(x['CHROMOSOME']),]$POSITION
      curw <- as.numeric(x['POSITION'])
      min(ifelse(chrw > curw, chrw - curw, curw - chrw))
    })
    q <- ifelse(q < 0, -q, q)
    longing <- rbind(longing, notYet[grep(max(q), q)[1],])
    notYet <- notYet[-grep(max(q), q)[1],]
  }
  least_distance <- longing %>% arrange(CHROMOSOME, POSITION) %>% group_by(CHROMOSOME) %>%
    mutate(remainder_before = POSITION - lag(POSITION, default = NA),
           remainder_after = lead(POSITION, default = NA) - POSITION) %>%
    #mutate(remainder_before = if_else(remainder_before > 0, remainder_before, -remainder_before),
    #       remainder_before = if_else(remainder_after > 0, remainder_after, -remainder_after)) %>%
    filter(min(if_else(!is.na(remainder_before), remainder_before, 1000000000L)) == remainder_before |
             min(if_else(!is.na(remainder_after), remainder_after, 1000000000L)) == remainder_after) %>%
    filter(min(if_else(min(remainder_before) == remainder_before, as.integer(NA), remainder_before),
               if_else(min(remainder_after) == remainder_after, as.integer(NA), remainder_after), na.rm = TRUE) == remainder_before |
             min(if_else(min(remainder_before) == remainder_before, as.integer(NA), remainder_before),
                 if_else(min(remainder_after) == remainder_after, as.integer(NA), remainder_after), na.rm = TRUE) == remainder_after) %>%
    ungroup() %>% filter(min(remainder_before, remainder_after, na.rm = TRUE) == remainder_before |
                           min(remainder_before, remainder_after, na.rm = TRUE) == remainder_after)
  message("The shortest distance between 2 mutations on the same chromosome is ", min(least_distance$remainder_before, least_distance$remainder_after))
  return(longing)
}
Sys.time()
arguments = commandArgs(trailingOnly=TRUE)
# get the last saved fasta file
blasted <- file.info(paste0(list.files(ifelse(!is.na(arguments[2]), arguments[2], "."), pattern = "fasta")))
fasta.file <- rownames(blasted[with(blasted, order(mtime, decreasing = TRUE)), ][1,])
chrpos <- strsplit(sub("..$", "", unique(names(readDNAStringSet(fasta.file)))), ",")
positions <- data.frame(chromosome = as.numeric(mapply(`[`, chrpos, 1)),
                       position = as.numeric(mapply(`[`, chrpos, 2)))
if (!is.na(arguments[1])) db = arguments[1] else db = Sys.glob("/d*/d*/eight.db")
eightnucleotide <- dbConnect(SQLite(), db)
dbWriteTable(eightnucleotide, "FILTERED_VALIDATE_FR", positions, overwrite = TRUE)
if ("EXULANS_VALID" %in% dbListTables(eightnucleotide)) dbRemoveTable(eightnucleotide, "EXULANS_VALID")
# inner join on filtered positions and exulans table
dbExecute(eightnucleotide, "CREATE TABLE IF NOT EXISTS EXULANS_VALID AS SELECT * FROM EXULANS INNER JOIN FILTERED_VALIDATE_FR ON EXULANS.POSITION = FILTERED_VALIDATE_FR.position AND EXULANS.CHROMOSOME = FILTERED_VALIDATE_FR.chromosome;")
exulans <- tbl(eightnucleotide, "EXULANS_VALID")
# get SNPs
deeper <- exulans %>% collect()
# sla haplotypes op in losse variablen
deeper$GENOTYPE.LEFT <- mapply(`[`, strsplit(deeper$GENOTYPE_BP, "/"), 1)
deeper$GENOTYPE.RIGHT <- mapply(`[`, strsplit(deeper$GENOTYPE_BP, "/"), 2)
deeper %>% group_by(CHROMOSOME, POSITION) %>% summarise(n()) %>% ungroup() %>% summarise(n())
# group on equal genotypes per SNP
# and remove homozygote SNPs
searchterm <- deeper %>% group_by(CHROMOSOME, POSITION, GENOTYPE_BP, REFERENCE) %>%
  summarise(HOW_MUCH_GENOTYPE = n(), DIST_N = min(DIST_N), DIST_P = min(DIST_P)) %>% group_by(CHROMOSOME, POSITION, REFERENCE) %>% summarise(divergents = n_distinct(GENOTYPE_BP), DIST_N = min(DIST_N), DIST_P = min(DIST_P), records = sum(HOW_MUCH_GENOTYPE, na.rm = TRUE), max_genotype = if_else(8L-sum(HOW_MUCH_GENOTYPE, na.rm = TRUE) > max(HOW_MUCH_GENOTYPE), 8L-sum(HOW_MUCH_GENOTYPE, na.rm = TRUE), max(HOW_MUCH_GENOTYPE)), all_bases = paste0(GENOTYPE_BP, collapse = "/"))  %>% # how many divergents genotypes there are
  mutate(divergents = if_else(records!=8L, divergents+1L, divergents), all_bases = if_else(records!=8L, paste(alle_bases, REFERENCE, sep = "/"), alle_bases)) # remove all homozygote thereof
searchterm %>% ungroup() %>% summarise(n())

# number of SNPs that not occur in only 1 sample
searchterm %>% filter(divergents > 1) %>% ungroup() %>% summarise(n())
# SNPs with 3 divergent basen are removed from searchterm
searchterm <- searchterm [mapply(function(x) 3>length(unique(x)), strsplit(searchterm
                                                                         $alle_bases, '/')),]
# table that the number of genotypes/ how many does the most occuring occur
deep <- searchterm %>% filter(divergents > 1) %>% group_by(divergents, max_genotype) %>% summarise(amount = n())
deep$`Most
occurring
genotype` <- as.character(deep$max_genotype)
deep$divergents <- as.character(deep$divergents)
heterozygote <- searchterm %>% filter(divergents == 3) %>% collect()
no_seven <- searchterm %>% filter(divergents == 2, !(max_genotype == 7 & divergents == 2)) %>% collect()
seven <- searchterm %>% filter(divergents > 1, (max_genotype == 7 & divergents == 2)) %>% collect()

# full <- rbind(no_seven[sample(1:nrow(no_seven), ifelse(100-nrow(heterozygote) > 0, 100-nrow(heterozygote), 0)),], heterozygote[if (nrow(heterozygote)<100) TRUE else 1:207,])
full <- removeNearest(rbind(heterozygote, no_seven), 259)

# full <- rbind(seven[sample(1:nrow(no_seven), ifelse(300-nrow(full) > 0, 300-nrow(full), 0)),], full[if (nrow(full)<300) TRUE else 1:300,])
# make a bar-diagram figure
ggplot(deep, aes(divergents, amount)) + geom_col(aes(fill = `Most
occurring
genotype`)) + xlab("Genotypes on SNP") + ylab("amount")
ggsave("temp.png")
bot <- TGBot$new(token = "TOKEN")
bot$sendPhoto("temp.png", "This is the polyformity distribution of EXULANS", chat_id = 0)
unlink("temp.png")
# show a row
seven[sample(1:nrow(seven), 1),]
meta.data <- full %>% group_by(divergents, max_genotype) %>% summarise(amount = n())
setwd("~/SNP-files/")
# store in database, and file
write.csv(full, "PRIMER_DESIGNER_opvullend.csv")
dbWriteTable(eightnucleotide, "SELECTED_OPVULLEND", full[,c("CHROMOSOME", "POSITION")], overwrite = TRUE)
selected <- tbl(eightnucleotide, "SELECTED_OPVULLEND")
# obtain using inner join all information from the selected SNPs
SNPs <- inner_join(exulans, selected, c(CHROMOSOME = "CHROMOSOME", POSITION = "POSITION")) %>% collect()
dbDisconnect(eightnucleotide)

SNPs <- SNPs[,-grep(":1", colnames(SNPs))]
SNPs$GENOTYPE <- SNPs$GENOTYPE_BP
# show how often a genotype occurs over the selected SNPs
table(SNPs$GENOTYPE_BP)
# summarise the data to 1 row per SNP
beterSNPs <- SNPs %>% group_by(CHROMOSOME, POSITION) %>% summarise(average.quality = mean(QUALITY), diff_gt = paste(dplyr::first(REFERENCE), paste0(GENOTYPE_BP, collapse = "/"), sep = "/"), average.coverage = mean(COVERAGE), REFERENCE = dplyr::first(as.character(REFERENCE)))
o2n <- sub(".*/", "", read.csv("/data/david.noteborn/sample-enum.csv", col.names = c("ORGANISM", "NUMBER"), header = FALSE, stringsAsFactors = FALSE)$ORGANISM)
o2n <- o2n[!duplicated(o2n)]
beterSNPs[,o2n] <- beterSNPs$REFERENCE
beterSNPs$diff_gt <- mapply(function(x) paste0(unique(x), collapse = "/"), strsplit(beterSNPs$diff_gt, "/"))
ggplot(data.frame(table(beterSNPs$CHROMOSOME)), aes(Var1, Freq)) + geom_col()
ggsave("SNPchromOpvullend.png")
invisible(apply(SNPs, 1, function(x) beterSNPs[beterSNPs$CHROMOSOME==as.numeric(x["CHROMOSOME"])&beterSNPs$POSITION==as.numeric(x["POSITION"]), o2n[as.numeric(x['ORGANISM'])]] <<- sub("(.)/\\1", "\\1", x["GENOTYPE"])))
beterSNPs
setwd(Sys.glob("/d*/*/blast_output/100arbitrair/"))
# retrieve the sequences
# retrieve the latest file
blasted <- file.info(paste0(list.files(pattern = "fasta")))
fasta.file <- rownames(blasted[with(blasted, order(mtime, decreasing = TRUE)), ][1,])
# read the file
fasta <- readDNAStringSet(fasta.file)
q <- apply(beterSNPs, 1, function(x) {
  sel <- grep(paste(as.numeric(x["CHROMOSOME"]), as.numeric(x["POSITION"]), sep = ","), names(fasta))
  if (length(sel)!=0) {
    cat(sel)
    beterSNPs[as.numeric(x["CHROMOSOME"])==beterSNPs$CHROMOSOME&beterSNPs$POSITION==as.numeric(x["POSITION"]),"sequence.before"] <<- toString(fasta[sel[1]])
    beterSNPs[as.numeric(x["CHROMOSOME"])==beterSNPs$CHROMOSOME&beterSNPs$POSITION==as.numeric(x["POSITION"]),"sequence.after"] <<- toString(fasta[sel[2]])
  }
})
setwd(paste0(Sys.getenv("HOME"), "/SNP-files/"))
beterSNPs <- beterSNPs[!is.na(beterSNPs$sequence.before),]
# make plots that show the distribution of the SNPs
ggplot(beterSNPs, aes(CHROMOSOME, POSITION)) + geom_violin() + geom_jitter(height = 0, width = 0.1) + ggtitle("Neurotransmitter")
ggsave("neurotransmitter-distribution-filled.png")
ggplot(beterSNPs, aes(TRUE, POSITION)) + geom_violin() + geom_dotplot(binaxis='y', stackdir='center') + ggtitle("distribution over positions")
ggsave("violin-distribution-filled.png")
View(beterSNPs)
# save the data as csv
write.csv(beterSNPs, "SNP-filled.csv", row.names = FALSE, quote = FALSE)
# check whether (all) individual samples could be seperated by a SNP (and which one)
combinations <- combn(o2n, 2)
rownames(combinations) <- c("first", "second")
colnames(combinations) <- apply(combinations, 2, function(x){
  paste0(head(beterSNPs[beterSNPs[,x['first']]!=beterSNPs[,x['second']]&!grepl("/", beterSNPs[,x['first']][[1]])&!grepl("/", beterSNPs[,x['second']][[1]]),c("CHROMOSOME", "POSITION")], 1), collapse = "-")
  })
combinations
# format for primer design...
# (nevertheless without gene/GO data)
writeLines(paste0("CHR", beterSNPs$CHROMOSOME, "_", beterSNPs$POSITION, "\t", beterSNPs$sequence.before, "{", beterSNPs$diff_gt, "}", beterSNPs$sequence.after), "SNP-filled.txt")
# write.table(beterSNPs[,c("CHROMOSOME", "POSITION")], "verwerkSNPpos.ssv", sep = ",", row.names = FALSE)
# sed -nE '1!s/([0-9]+),([0-9]+),.*"([^"]+)","([^"]+)"/>\1-\2 before\n\3\n>\1-\2 after\n\4/p' SNP_V1.csv > SNP_V1.fasta
# sed -nE '1!s/([0-9]+),([0-9]+),.*,([^,]+),([^,]+)$/>\1-\2 before\n\3\n>\1-\2 after\n\4/p' SNP_V2.csv > SNP_V2.fasta
