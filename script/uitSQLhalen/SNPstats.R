#!/usr/bin/env Rscript
#SBATCH --job-name=distkwaliteit
# maak coverage plot
# by david
# write.csv("diepte1.csv")
# diepte <- read.csv("diepte1.csv", row.names = 1)
library(RSQLite)
library(dplyr, warn.conflicts = FALSE)
library(telegram)
library(ggplot2)
Sys.time()
eightnucleotide <- dbConnect(SQLite(), "/data/david.noteborn/acht.db")
exulans <- tbl(eightnucleotide, "EXULANS_VALID")
# SELECT COUNT(VERSCHILLENDE), VERSCHILLENDE FROM (select COUNT(DISTINCT GENOTYPE || "_" || ALTERNATIVE) AS VERSCHILLENDE FROM EXULANS_VALID GROUP BY CHROMOSOME, POSITION) GROUP BY VERSCHILLENDE;
zoekterm <- exulans %>% group_by(chromosome, position, FENOTYPE = paste0(GENOTYPE, "_", ALTERNATIVE)) %>%
  summarise(HOEVEEL_FENOTYPE = count()) %>% ungroup() %>% group_by(chromosome, position) %>% # wat is het aantal dat men van een fenotype heeft
  summarise(verschillende = n_distinct(FENOTYPE), records = sum(HOEVEEL_FENOTYPE, na.rm = TRUE), max_fenotype = if_else(8-sum(HOEVEEL_FENOTYPE, na.rm = TRUE) > max(HOEVEEL_FENOTYPE), 8-sum(HOEVEEL_FENOTYPE, na.rm = TRUE), max(HOEVEEL_FENOTYPE)))  %>% # hoeveel verschillende fenotypes zijn er
  mutate(verschillende = if_else(records!=8L, verschillende+1L, verschillende)) %>% # als het er geen 8 zijn
  filter(!verschillende==1L) %>% group_by(verschillende, max_fenotype) %>% summarise(aantal = count()) # haal homozygote weg hoeveel daarvan
zoekterm %>% show_query()
diepte <- zoekterm %>% collect()
dbDisconnect(eightnucleotide)
diepte$max_fenotype <- as.character(diepte$max_fenotype)
ggsave("temp.png", ggplot(diepte, aes(verschillende, aantal)) + geom_col(aes(fill = max_fenotype)) + xlab("Verschillende mogelijkheden voor SNP") + ylab("aantal"))
Sys.time()
bot <- TGBot$new(token = "TOKEN")
bot$sendPhoto("temp.png", "Dit is de polyformiteit distributie van EXULANS", chat_id = 454771972)
unlink("temp.png")
write.csv(diepte, "coverage.csv")
# pak SNPs
dieper <- exulans %>% collect()
dieper$GENOTYPE.LEFT <- as.numeric(mapply(`[`, strsplit(dieper$GENOTYPE, "/"), 1))
dieper$GENOTYPE.RIGHT <- as.numeric(mapply(`[`, strsplit(dieper$GENOTYPE, "/"), 2))
dieper$KEUZE <- paste(dieper$REFERENCE, dieper$ALTERNATIVE, sep = ",")
dieper$GENOTYPE <- apply(dieper, 1, function(x) paste0(strsplit(x["KEUZE"], ",")[[1]][1+as.numeric(x['GENOTYPE.LEFT'])], "/", strsplit(x["KEUZE"], ",")[[1]][1+as.numeric(x['GENOTYPE.RIGHT'])]))


zoekterm <- dieper %>% group_by(CHROMOSOME, POSITION, GENOTYPE) %>%
  summarise(HOEVEEL_FENOTYPE = n(), DIST_N = min(DIST_N), DIST_P = min(DIST_P)) %>% group_by(CHROMOSOME, POSITION) %>% summarise(verschillende = n_distinct(GENOTYPE), DIST_N = min(DIST_N), DIST_P = min(DIST_P), records = sum(HOEVEEL_FENOTYPE, na.rm = TRUE), max_fenotype = if_else(8L-sum(HOEVEEL_FENOTYPE, na.rm = TRUE) > max(HOEVEEL_FENOTYPE), 8L-sum(HOEVEEL_FENOTYPE, na.rm = TRUE), max(HOEVEEL_FENOTYPE)))  %>% # hoeveel verschillende fenotypes zijn er
  mutate(verschillende = if_else(records!=8L, verschillende+1L, verschillende)) # haal homozygote weg hoeveel daarvan
geeenzeven <- zoekterm %>% filter(verschillende > 1, DIST_N > 299, DIST_P > 299, !(max_fenotype == 7 & verschillende == 2))
rest <- geeenzeven %>% collect()
zeven <- zoekterm %>% filter(verschillende > 1, DIST_N > 299, DIST_P > 299, (max_fenotype == 7 & verschillende == 2))
meer <- zeven %>% collect()
volledig <- rbind(meer[sample(1:nrow(meer), 300-nrow(rest)),], rest)
meer[sample(1:nrow(meer), 1),]
meta.data <- volledig %>% group_by(verschillende, max_fenotype) %>% summarise(aantal = n())
write.csv(rest, "PRIMER_DESIGN.csv")
dbWriteTable(eightnucleotide, "SELECTED", volledig[,c("CHROMOSOME", "POSITION")], overwrite = TRUE)
# .separator "\t"
# .output "PRIMER_SNP.csv"
# SELECT * FROM SELECTED INNER JOIN EXULANS_VALID ON SELECTED.POSITION = EXULANS_VALID.position AND SELECTED.CHROMOSOME = EXULANS_VALID.chromosome;
SNPs <- read.csv("/data/david.noteborn/PRIMER_SNP.csv", sep = "\t")
SNPs <- SNPs[,-grep(".1", colnames(SNPs))]
SNPs$GENOTYPE.LEFT <- as.numeric(mapply(`[`, strsplit(as.character(SNPs$GENOTYPE), "/"), 1))
SNPs$GENOTYPE.RIGHT <- as.numeric(mapply(`[`, strsplit(as.character(SNPs$GENOTYPE), "/"), 2))
SNPs$KEUZE <- paste(SNPs$REFERENCE, SNPs$ALTERNATIVE, sep = ",")
SNPs$GENOTYPE <- apply(SNPs, 1, function(x) paste0(strsplit(x["KEUZE"], ",")[[1]][1+as.numeric(x['GENOTYPE.LEFT'])], "/", strsplit(x["KEUZE"], ",")[[1]][1+as.numeric(x['GENOTYPE.RIGHT'])]))
beterSNPs <- SNPs %>% group_by(CHROMOSOME, POSITION) %>% summarise(average.quality = mean(QUALITY), average.coverage = mean(COVERAGE), REFERENCE = dplyr::first(as.character(REFERENCE)))
o2n <- read.csv("/data/david.noteborn/sample-enum.csv", col.names = c("ORGANISM", "NUMBER"), header = FALSE, stringsAsFactors = FALSE)$ORGANISM
beterSNPs[,o2n] <- beterSNPs$REFERENCE
ggplot(data.frame(table(beterSNPs$CHROMOSOME)), aes(Var1, Freq)) + geom_col()
invisible(apply(SNPs, 1, function(x) beterSNPs[beterSNPs$CHROMOSOME==as.numeric(x["CHROMOSOME"])&beterSNPs$POSITION==as.numeric(x["POSITION"]), o2n[as.numeric(x['ORGANISM'])]] <<- sub("(.)/\\1", "\\1", x["GENOTYPE"])))
setwd("/data/david.noteborn/blast_output/")
# neem het nieuwste bestand
blasted <- file.info(paste0(list.files(pattern = "fasta")))
fasta.bestand <- rownames(blasted[with(blasted, order(mtime, decreasing = TRUE)), ][1,])
# lees het in
fasta <- readDNAStringSet(fasta.bestand)
q <- apply(beterSNPs, 1, function(x) {
  sel <- grep(paste(as.numeric(x["CHROMOSOME"]), as.numeric(x["POSITION"]), sep = ","), names(fasta))
  beterSNPs[as.numeric(x["CHROMOSOME"])==beterSNPs$CHROMOSOME&beterSNPs$POSITION==as.numeric(x["POSITION"]),"sequentie.voor"] <<- toString(fasta[sel[1]])
  beterSNPs[as.numeric(x["CHROMOSOME"])==beterSNPs$CHROMOSOME&beterSNPs$POSITION==as.numeric(x["POSITION"]),"sequentie.na"] <<- toString(fasta[sel[2]])
})
setwd(Sys.getenv("HOME"))
beterSNPs
write.csv(beterSNPs, "SNP_V2.csv", row.names = FALSE, quote = FALSE)
combinaties <- combn(o2n, 2)
rownames(combinaties) <- c("eerste", "tweede")
colnames(combinaties) <- apply(combinaties, 2, function(x) paste0(head(beterSNPs[beterSNPs[,x['eerste']]!=beterSNPs[,x['tweede']]&!grepl("/", beterSNPs[,x['eerste']][[1]])&!grepl("/", beterSNPs[,x['tweede']][[1]]),c("CHROMOSOME", "POSITION")], 1), collapse = "-"))
combinaties
# sed -nE '1!s/([0-9]+),([0-9]+),.*"([^"]+)","([^"]+)"/>\1-\2 voor\n\3\n>\1-\2 na\n\4/p' SNP_V1.csv > SNP_V1.fasta
# sed -nE '1!s/([0-9]+),([0-9]+),.*,([^,]+),([^,]+)$/>\1-\2 voor\n\3\n>\1-\2 na\n\4/p' SNP_V2.csv > SNP_V2.fasta