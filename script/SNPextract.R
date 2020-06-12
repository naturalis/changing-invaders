#!/usr/bin/env Rscript
#SBATCH --job-name=SNPfinal
# changing invaders
# extract SNPs (last step)
# by david
library(RSQLite)
library(dplyr, warn.conflicts = FALSE)
library(telegram)
library(ggplot2)
suppressPackageStartupMessages(library(Biostrings))
# multiple arguments:
#  1. number of required SNPs (or nothing)
#  2. database file (or nothing)
#  3. sample-enum file (or nothing)
#  4. blast directory (or nothing)
#  5. SNP directory (or nothing)
#  6. posfix for output names (or nothing)
arguments = commandArgs(trailingOnly=TRUE)
number_snps = if (!is.na(arguments[1])) as.integer(arguments[1]) else 100 # 1.
database_file = if (!is.na(arguments[2])) arguments[2] else Sys.glob("/d*/d*/eight.db") # 2.
sample_enum = if (!is.na(arguments[3])) arguments[3] else Sys.glob("/d*/d*/sample-enum.csv") # 3.
# get the last saved fasta file
folder_to_blast_directory = ifelse(!is.na(arguments[4]), arguments[4], ".") # 4.
if (!dir.exists(folder_to_blast_directory)) stop("The folder to the BLAST directory supplied, could not be found.")
files_in_blast_directory = list.files(folder_to_blast_directory, pattern = "\\.fasta$")
if (length(files_in_blast_directory)==0) stop("The blast directory supplied, or the default directory, could not be found.")
blasted <- file.info(paste0(folder_to_blast_directory, files_in_blast_directory))
fasta.file <- rownames(blasted[with(blasted, order(mtime, decreasing = TRUE)), ][1,])
output_directory = if (!is.na(arguments[5])) arguments[5] else paste0(Sys.getenv("HOME"), "/SNP-files/") # 5.
postfix_name = if (!is.na(arguments[6])) arguments[6] else "data" # 6.
# checks if all the files exists
if (!file.exists(database_file)) stop("The database supplied, or the default database, could not be found.")
if (!file.exists(sample_enum)) stop("The sample-enum file supplied, or the default sample-enum, could not be found.")
if (!dir.exists(output_directory)) stop("The output directory supplied, or the default output directory, could not be found.")
# this is the second function written for this purpose
# the distance parameter represent a dataframe containing the SNPs
# remain the number of SNPs one would like to approximately obtain
# longed are SNPs that should be added anyway
# as a return value, exact the data as in distance, but now approximately the number in 'remain', and optimized on distance, as far as it is possible
removeNearest <- function(distance, remain = number_snps, longed = NULL) {
  # longing == all taken SNPs
  # notYet == rest
  # while more SNPs should be added, calculate the minimal distance of every in rest related to all
  # longing. Is that distance maxed, add to longing
  #
  # longing is first filled with the very first and the very last SNP
  longing <- distance %>% arrange(CHROMOSOME, POSITION) %>% group_by(CHROMOSOME) %>% filter(row_number() == 1 | row_number() == n())
  # if there are more standard-to-include SNPs add them
  # it does not work perfectly right, but it might do the job
  if (!is.null(longed)) longing <- rbind(longing, longed)
  notYet <- distance %>% arrange(CHROMOSOME, POSITION) %>% group_by(CHROMOSOME) %>% filter(!(row_number() == 1 | row_number() == n()))
  
  while (nrow(longing) != remain & nrow(notYet) != 0) {
    q <- apply(notYet, 1, function(x) {
      chrw <- longing[longing$CHROMOSOME == as.numeric(x['CHROMOSOME']),]$POSITION
      curw <- as.numeric(x['POSITION'])
      min(ifelse(chrw > curw, chrw - curw, curw - chrw))
    })
    q <- ifelse(q < 0, -q, q)
    print(q)
    longing <- rbind(longing, notYet[grep(max(q), q)[1],])
    notYet <- notYet[-grep(max(q), q)[1],]
  }
  least_distance <- longing %>% arrange(CHROMOSOME, POSITION) %>% group_by(CHROMOSOME) %>%
    mutate(remainder_before = POSITION - lag(POSITION, default = NA),
           remainder_after = lead(POSITION, default = NA) - POSITION) %>%
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
# this is the third function for this purpose
# this functions would optimize distance by summing up all the distance between the first and last SNP
# on every chromosome, and dividing the length by the required number of SNPs (- the already placed)
# this has the downside of having a chance to not get the exact number of SNPs (because of rounding),
# but this could be fixed by a wrapper function that increments remain, until it equals, or exceeds the
# required as a return value if a chromosome has less SNPs, than would be the result of best spreading,
# the maximum SNPs of that chromosome are taken, and the best spread is modified for this
#
# this might not be the best solution that one ever can find, but this will work with a (small) wealth of SNPs
# the distance parameter represent a dataframe containing the SNPs
# remain the number of SNPs one would like to approximately obtain
# longed are SNPs that should be added anyway
# as a return value, exact the data as in distance, but now approximately the number in 'remain', and optimized on distance, as far as it is possible
HD <- function(distance, remain = number_snps, longed = NULL) {
  # longing == all taken SNPs
  # notYet == rest
  if (nrow(distance) < 2 & is.null(longed)) stop("The data contains too few SNPs")
  if (nrow(distance) < 20 & is.null(longed)) warning("The data contains few SNPs")
  # longing is first filled with the very first and the very last SNP
  longing <- distance %>% arrange(CHROMOSOME, POSITION) %>% group_by(CHROMOSOME) %>% filter(row_number() == 1 | row_number() == n())
  # if there are more standard-to-include SNPs add them
  # it does not work perfectly right, but it might do the job
  if (!is.null(longed)) longing <- rbind(longing, longed)
  # all the rest is not yet in there
  notYet <- distance %>% arrange(CHROMOSOME, POSITION) %>% group_by(CHROMOSOME) %>% filter(!(row_number() == 1 | row_number() == n()))
  # make a table that contains chromosome number, number between the very first and the very last (included)SNP and the position of the first
  area_table <- longing %>% group_by(CHROMOSOME) %>% mutate(diff = POSITION-lag(POSITION, default=NA), increment = dplyr::first(POSITION)) %>%
   select(CHROMOSOME, diff, increment) %>% filter(!is.na(diff))
  area_table$nSNPs <- round((area_table$diff / sum(area_table$diff)) * (remain - nrow(longing)))
  area_table <- merge(area_table, notYet %>% group_by(CHROMOSOME) %>% summarise(max_amount = n()), by = "CHROMOSOME")
  remain_proportion <- remain
  # while there are chromosomes that 'should' have more SNPs that are found on the vcf file
  # downsize that number and recalculate the number for each chromosome
  while (!all(area_table$max_amount - area_table$nSNPs >= 0)) {
   warning("some chromosomes do have 'too few' SNPs, depending on the number of times one gets this message, this might be more serious")
   area_table_proportion <- area_table[area_table$max_amount - area_table$nSNPs >= 0,]
   area_table_static_new <- area_table[!area_table$max_amount - area_table$nSNPs >= 0,]
   area_table_static_new$nSNPs <- area_table_static_new$max_amount
   area_table_static <- if (exists("area_table_static")) rbind(area_table_static, area_table_static_new) else area_table_static_new
   # calculate the number of SNPs that are to be divided
   remain_proportion <- remain - (area_table_static %>% summarise(sum(max_amount)))
   area_table_proportion$nSNPs <- round((area_table_proportion$diff / sum(area_table_proportion$diff)) * (remain_proportion - nrow(longing)))
   area_table <- area_table_proportion
  }
  if (exists("area_table_static")) area_table <- rbind(area_table_static, area_table_proportion) 
  # nSNPs could be a list at this point so a conversion might be required
  area_table$nSNPs <- as.integer(area_table$nSNPs)
  best_distance <- do.call(rbind, apply(area_table, 1, function(x) data.frame(location = x['increment'] + (1:(x['nSNPs']+1)/(x['nSNPs']+1))*x['diff'], chromosome = x['CHROMOSOME'], row.names = c())[1:x['nSNPs'],]))

  # while the number of SNPs is not the required one and there are SNPs left
  while (nrow(longing) != remain & nrow(notYet) != 0 & nrow(best_distance) != 0) {
   # for each chromosome
   for (current_chromosome in unique(best_distance$chromosome)) {
    # get all the chromosome distances
    # as integer because else one gets weird numbers
    print(as.integer(notYet$POSITION[notYet$CHROMOSOME==current_chromosome]))
    print(as.integer(best_distance$location[best_distance$chromosome==current_chromosome]))
    distance_table <- abs(outer(as.integer(best_distance$location[best_distance$chromosome==current_chromosome]),
     as.integer(notYet$POSITION[notYet$CHROMOSOME==current_chromosome]), "-"))
    # get the nearest SNP to the best distance possible table
    what <- which(min(distance_table)==distance_table, arr.ind = TRUE)
    # append it to the included SNPs
    longing <- rbind(longing, notYet[which(notYet$CHROMOSOME==current_chromosome)[what[, "col"]],])
    # remove the best distance position from notYet
    best_distance <- best_distance[-which(best_distance$chromosome==current_chromosome)[what[, "row"]],]
    rownames(best_distance) <- NULL # else the row names doesn't match up (might give problems)
    notYet <- notYet[-which(notYet$CHROMOSOME==current_chromosome)[what[, "col"]],]
   }
  }
  # uses the same shortest distance calculation of the previous algorithm
  least_distance <- longing %>% arrange(CHROMOSOME, POSITION) %>% group_by(CHROMOSOME) %>%
    mutate(remainder_before = POSITION - lag(POSITION, default = NA),
           remainder_after = lead(POSITION, default = NA) - POSITION) %>%
    filter(min(if_else(!is.na(remainder_before), remainder_before, 1000000000L)) == remainder_before |
             min(if_else(!is.na(remainder_after), remainder_after, 1000000000L)) == remainder_after) %>%
    filter(min(if_else(min(remainder_before) == remainder_before, as.integer(NA), remainder_before),
               if_else(min(remainder_after) == remainder_after, as.integer(NA), remainder_after), na.rm = TRUE) == remainder_before |
             min(if_else(min(remainder_before) == remainder_before, as.integer(NA), remainder_before),
                 if_else(min(remainder_after) == remainder_after, as.integer(NA), remainder_after), na.rm = TRUE) == remainder_after) %>%
    ungroup() %>% filter(min(remainder_before, remainder_after, na.rm = TRUE) == remainder_before |
                           min(remainder_before, remainder_after, na.rm = TRUE) == remainder_after)
  message("The shortest distance between 2 mutations on the same chromosome is ", min(least_distance$remainder_before, least_distance$remainder_after))
  if (nrow(best_distance) == 0 & nrow(longing) != remain)
   warning("There is a condition where by dividing the chromosomes, there are some SNPs lost, so the resulting SNPs will be less (or more) than asked for") else {
   if (nrow(longing) != remain) warning("There are less or more SNPs selected than there was asked for")
  }
  return(longing)
}
chrpos <- strsplit(sub("..$", "", unique(names(readDNAStringSet(fasta.file)))), ",")
positions <- data.frame(chromosome = as.numeric(mapply(`[`, chrpos, 1)),
                       position = as.numeric(mapply(`[`, chrpos, 2)))

eightnucleotide <- dbConnect(SQLite(), database_file)
exulans_valid_table <- paste0("EXULANS_VALID_", toupper(postfix_name))
filtered_validate_table <- paste0("FILTERED_VALIDATE_", toupper(postfix_name))
dbWriteTable(eightnucleotide, filtered_validate_table, positions, overwrite = TRUE)
if (exulans_valid_table %in% dbListTables(eightnucleotide)) dbRemoveTable(eightnucleotide, exulans_valid_table)
# inner join on filtered positions and exulans table
dbExecute(eightnucleotide, paste0("CREATE TABLE IF NOT EXISTS ", exulans_valid_table, " AS SELECT * FROM EXULANS INNER JOIN ", filtered_validate_table, " ON EXULANS.POSITION = ", filtered_validate_table, ".position AND EXULANS.CHROMOSOME = ", filtered_validate_table, ".chromosome;"))
exulans <- tbl(eightnucleotide, exulans_valid_table)
# get SNPs
deeper <- exulans %>% collect()
deeper %>% group_by(CHROMOSOME, POSITION) %>% summarise(n()) %>% ungroup() %>% summarise(n())
# group on equal genotypes per SNP
# and remove homozygote SNPs
searchterm <- deeper %>% group_by(CHROMOSOME, POSITION, GENOTYPE_BP, REFERENCE) %>%
  summarise(AMOUNT_GENOTYPE = n(), DIST_N = min(DIST_N), DIST_P = min(DIST_P)) %>%
  group_by(CHROMOSOME, POSITION, REFERENCE) %>%
  summarise(divergents = n_distinct(GENOTYPE_BP), DIST_N = min(DIST_N), DIST_P = min(DIST_P), records = sum(AMOUNT_GENOTYPE, na.rm = TRUE),
  max_genotype = if_else(8L-sum(AMOUNT_GENOTYPE, na.rm = TRUE) > max(AMOUNT_GENOTYPE), 8L-sum(AMOUNT_GENOTYPE, na.rm = TRUE), max(AMOUNT_GENOTYPE)),
  all_bases = paste0(GENOTYPE_BP, collapse = "/"))  %>% # how many divergents genotypes there are
  mutate(divergents = if_else(records!=8L, divergents+1L, divergents), all_bases = if_else(records!=8L, paste(all_bases, REFERENCE, sep = "/"), all_bases)) # remove all homozygote thereof
searchterm %>% ungroup() %>% summarise(n())

# number of SNPs that not occur in only 1 sample
searchterm %>% filter(divergents > 1) %>% ungroup() %>% summarise(n())
# SNPs with 3 divergent basen are removed from searchterm
searchterm <- searchterm [mapply(function(x) 3>length(unique(x)), strsplit(searchterm$all_bases, '/')),]
# table that the number of genotypes/ how many does the most occuring occur
deep <- searchterm %>% filter(divergents > 1) %>% group_by(divergents, max_genotype) %>% summarise(amount = n())
deep$`Most
occurring
genotype` <- as.character(deep$max_genotype)
deep$divergents <- as.character(deep$divergents)
heterozygote <- searchterm %>% filter(divergents == 3) %>% collect()
no_seven <- searchterm %>% filter(divergents == 2, !(max_genotype == 7 & divergents == 2)) %>% collect()
seven <- searchterm %>% filter(divergents > 1, (max_genotype == 7 & divergents == 2)) %>% collect()

# full <- rbind(no_seven[sample(1:nrow(no_seven), ifelse(number_snps-nrow(heterozygote) > 0, number_snps-nrow(heterozygote), 0)),], heterozygote[if (nrow(heterozygote)<number_snps) TRUE else 1:207,])
full <- HD(rbind(heterozygote, no_seven), number_snps)
if (nrow(full)<number_snps) full <- HD(seven, number_snps, full)
if (nrow(full)<number_snps) warning("Less than the asked SNPs are given:\n", number_snps, " were asked, while ", nrow(full), " were given.")
# full <- rbind(seven[sample(1:nrow(no_seven), ifelse(number_snps-nrow(full) > 0, number_snps-nrow(full), 0)),], full[if (nrow(full)<number_snps) TRUE else 1:number_snps,])
# make a bar-diagram figure
ggplot(deep, aes(divergents, amount)) + geom_col(aes(fill = `Most
occurring
genotype`)) + xlab("Genotypes on SNP") + ylab("amount")
# ggsave("temp.png");bot <- TGBot$new(token = "TOKEN");bot$sendPhoto("temp.png", "This is the polyformity distribution of EXULANS", chat_id = 0);unlink("temp.png")
# show a row
seven[sample(1:nrow(seven), 1),]
meta.data <- full %>% group_by(divergents, max_genotype) %>% summarise(amount = n())
# store in database, and file
write.csv(full, paste0(output_directory, "/PRIMER_DESIGNER_", postfix_name, ".csv"))
dbWriteTable(eightnucleotide, paste0("SELECTED_", toupper(postfix_name)), full[,c("CHROMOSOME", "POSITION")], overwrite = TRUE)
selected <- tbl(eightnucleotide, paste0("SELECTED_", toupper(postfix_name)))
# obtain using inner join all information from the selected SNPs
SNPs <- inner_join(exulans, selected, c(CHROMOSOME = "CHROMOSOME", POSITION = "POSITION")) %>% collect()
dbDisconnect(eightnucleotide)

SNPs <- SNPs[,-grep(":1", colnames(SNPs))]
SNPs$GENOTYPE <- SNPs$GENOTYPE_BP
# show how often a genotype occurs over the selected SNPs
table(SNPs$GENOTYPE_BP)
# summarise the data to 1 row per SNP
beterSNPs <- SNPs %>% group_by(CHROMOSOME, POSITION) %>% summarise(average.quality = mean(QUALITY), diff_gt = paste(dplyr::first(REFERENCE), paste0(GENOTYPE_BP, collapse = "/"), sep = "/"), average.coverage = mean(COVERAGE), REFERENCE = dplyr::first(as.character(REFERENCE)))
o2n <- sub(".*/", "", read.csv(sample_enum, col.names = c("ORGANISM", "NUMBER"), header = FALSE, stringsAsFactors = FALSE)$ORGANISM)
o2n <- o2n[!duplicated(o2n)]
beterSNPs[,o2n] <- beterSNPs$REFERENCE
beterSNPs$diff_gt <- mapply(function(x) paste0(unique(x), collapse = "/"), strsplit(beterSNPs$diff_gt, "/"))
ggplot(data.frame(table(beterSNPs$CHROMOSOME)), aes(Var1, Freq)) + geom_col()
ggsave(paste0(output_directory, "/SNPchrom_", postfix_name, ".png"))
invisible(apply(SNPs, 1, function(x) beterSNPs[beterSNPs$CHROMOSOME==as.numeric(x["CHROMOSOME"])&beterSNPs$POSITION==as.numeric(x["POSITION"]), o2n[as.numeric(x['ORGANISM'])]] <<- sub("(.)/\\1", "\\1", x["GENOTYPE"])))
beterSNPs
# retrieve the sequences
# read the file
fasta <- readDNAStringSet(fasta.file)
q <- apply(beterSNPs, 1, function(x) {
  sel <- grep(paste(as.numeric(x["CHROMOSOME"]), as.numeric(x["POSITION"]), sep = ","), names(fasta))
  if (length(sel)!=0) {
    # cat(sel)
    where = (as.numeric(x["CHROMOSOME"])==beterSNPs$CHROMOSOME&beterSNPs$POSITION==as.numeric(x["POSITION"]))
    beterSNPs[where,"sequence.before"] <<- toString(fasta[sel[1]])
    beterSNPs[where,"sequence.after"] <<- toString(fasta[sel[2]])
  }
})
beterSNPs <- beterSNPs[!is.na(beterSNPs$sequence.before),]
# make plots that show the distribution of the SNPs
ggplot(beterSNPs, aes(CHROMOSOME, POSITION)) + geom_violin() + geom_jitter(height = 0, width = 0.1) + ggtitle("Neurotransmitter")
ggsave(paste0("neurotransmitter-distribution-", postfix_name, ".png"))
ggplot(beterSNPs, aes(TRUE, POSITION)) + geom_violin() + geom_dotplot(binaxis='y', stackdir='center') + ggtitle("distribution over positions")
ggsave(paste0("violin-distribution-", postfix_name, ".png"))
View(beterSNPs)
# save the data as csv
write.csv(beterSNPs, paste0(output_directory, "/SNP-", postfix_name, ".csv"), row.names = FALSE, quote = FALSE)
# check whether (all) individual samples could be seperated by a SNP (and which one)
combinations <- combn(o2n, 2)
rownames(combinations) <- c("first", "second")
colnames(combinations) <- apply(combinations, 2, function(x){
  paste0(head(beterSNPs[beterSNPs[,x['first']]!=beterSNPs[,x['second']]&!grepl("/", beterSNPs[,x['first']][[1]])&!grepl("/", beterSNPs[,x['second']][[1]]),c("CHROMOSOME", "POSITION")], 1), collapse = "-")
  })
combinations
# format for primer design...
# (nevertheless without gene/GO data)
writeLines(paste0("CHR", beterSNPs$CHROMOSOME, "_", beterSNPs$POSITION, "\t", beterSNPs$sequence.before, "{", beterSNPs$diff_gt, "}", beterSNPs$sequence.after), paste0(output_directory, "SNP-", postfix_name, ".txt"))
# write.table(beterSNPs[,c("CHROMOSOME", "POSITION")], "processSNPpos.ssv", sep = ",", row.names = FALSE)
# sed -nE '1!s/([0-9]+),([0-9]+),.*"([^"]+)","([^"]+)"/>\1-\2 before\n\3\n>\1-\2 after\n\4/p' SNP_V1.csv > SNP_V1.fasta
# sed -nE '1!s/([0-9]+),([0-9]+),.*,([^,]+),([^,]+)$/>\1-\2 before\n\3\n>\1-\2 after\n\4/p' SNP_V2.csv > SNP_V2.fasta
