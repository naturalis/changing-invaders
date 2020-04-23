#!/usr/bin/env Rscript
#SBATCH --job-name=filter-SNP
# filter SNPs
# by david
# biostrings is required (BiocManager::install("Biostrings"))
# based on uniek-meer.R
library(Biostrings)
library(telegram)
if (!is.na(commandArgs(trailingOnly=TRUE)[1])) pos = commandArgs(trailingOnly=TRUE)[1] else pos = "selected_snps.pos"
Sys.time()
filtered <- read.table(pos, col.names = c("chromosome", "position"))
# read the fasta file.
# this takes some time
DNA_sequence = readDNAStringSet(paste0(Sys.getenv("HOME"), "/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa"))
# edit the names so it is only the chromosome number
names(DNA_sequence) <- mapply(`[`, strsplit(names(DNA_sequence), " "), 1)
filtered <- filtered[filtered$chromosome!=0,]
sequences <- apply(filtered, 1, function(x) {
  if (length(DNA_sequence[[x["chromosome"]]])>as.numeric(x["position"])+250&as.numeric(x["position"])-250>0)
    toString(subseq(DNA_sequence[[x["chromosome"]]], start=as.numeric(x["position"])-250, end = as.numeric(x["position"])+250)) else NA
})
# add sequences to position table
filtered$before <- substr(sequences, 1, 250)
filtered$after <- substr(sequences, 252, 501)
filtered$ref <- substr(sequences, 251, 251)
filtered <- filtered[!is.na(sequences),]
# save it
setwd("/data/david.noteborn/blast_output")
old_runs <- file.info(dir(pattern = "oldrun"))
old_run <- paste0("oldrun.", 1+as.numeric(strsplit(rownames(old_runs[with(old_runs, order(mtime, decreasing = TRUE)), ][1,]), "\\.")[[1]][2]), "/")
dir.create(old_run)

moving <- list.files(pattern = ".(json|fasta|date|txt)$")
file.rename(moving, paste0(old_run, moving))
write.csv(filtered, "selected_snps.csv", quote = FALSE, row.names = FALSE)
# make a fasta of it
system("sed -nE '1!{s/([0-9]+,[0-9]+),([^,]+),([^,]+),(.)/>\\1-\\4\\n\\2\\n>\\1-\\4\\n\\3/p}' selected_snps.csv > selected_snps.fasta")
Sys.time()
bot <- TGBot$new(token = "939730741:AAHnRC-oDDSMJ_qjqmsxcrfcfWkJ6uaXm28")
SNP_message <- paste("There are", nrow(filtered), "SNPs remaining during the improved algorithm.")
bot$sendMessage(SNP_message, chat_id = 454771972)
cat(SNP_message)
setwd("..")
system("$HOME/blast_all_primers_no_remove.sh blast_output/selected_snps.fasta")
