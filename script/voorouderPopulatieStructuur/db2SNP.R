# maak 0.3k SNP bcf bestand
# zodat hierover een structuur analyse kan worden gedaan
# changing invders
# by david
library(RSQLite)
library(dplyr, warn.conflicts = FALSE)
# sed -En '/>.*voor/s/.(.*) .*/\1/p' SNP_V3.fasta > SNPOUT
# sed -En '1!s/,([^,]+).*/-\1/p' SNP_Vfinal.csv > SNPOUT
# sed -En '1!s/,([^,]+).*/-\1/p' SNP.csv > SNPOUT
SNPs <- read.table("SNP-files/SNPOUT", sep = "-", header = FALSE, col.names = c("CHR", "POS"))
eightnucleotide <- dbConnect(SQLite(), "/home/david.noteborn/onenucleotide_acht.db")
dbWriteTable(eightnucleotide, "CHOSEN", SNPs, overwrite = TRUE)
exulans <- tbl(eightnucleotide, "EXULANS")
about0.3kSNPsdb <- tbl(eightnucleotide, "CHOSEN")

about0.3kSNPs <- inner_join(exulans, about0.3kSNPsdb, c("CHROM" = "CHR", "POS" = "POS")) %>% collect()
writeLines(grep("##", readLines("vcfheader"), value = TRUE), "merge0.3k.vcf")
about0.3kSNPs$ID <- paste0("SNP_", 1:nrow(about0.3kSNPs))
about0.3kSNPs$FILTER <- "."
about0.3kSNPs$FORMAT <- "GT:PL"
about0.3kSNPs <- about0.3kSNPs[,c("CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", "INFO", "FORMAT",
                                  grep("^EXUL", colnames(about0.3kSNPs), value = TRUE))]
about0.3kSNPs <- cbind(about0.3kSNPs[,-grep("^EXUL", colnames(about0.3kSNPs))], sapply(grep("PL", colnames(about0.3kSNPs), value = TRUE), function(x) do.call(function(...)paste(..., sep = ":"), about0.3kSNPs[,c(sub("PL$", "GT", x), x)])))
colnames(about0.3kSNPs) <- sub("PL$", "", sub("CHROM", "#CHROM", colnames(about0.3kSNPs)))
suppressWarnings(write.table(about0.3kSNPs, "merge0.3k.vcf", sep = "\t", quote = FALSE, append = TRUE, row.names = FALSE))
