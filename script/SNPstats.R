#!/usr/bin/env Rscript
#SBATCH --job-name=SNPfinal
# extraheer SNPs (laatste stap)
# by david
# changing invaders
library(RSQLite)
library(dplyr, warn.conflicts = FALSE)
library(telegram)
library(ggplot2)
library(Biostrings)
haalDichtstBijzijnsteWeg <- function(afstand, overhouden = 100) {
  # verlangend == alle meegenomen SNPs
  # nogniet == rest
  # zolang er meer SNPs bij moeten, bereken de minimale afstand van iedere rest ten opzichte van alle
  # verlangend. Is die afstand maximaal, voeg het toe aan verlangend
  verlangend <- afstand %>% arrange(CHROMOSOME, POSITION) %>% group_by(CHROMOSOME) %>% filter(row_number() == 1 | row_number() == n())
  nogNiet <- afstand %>% arrange(CHROMOSOME, POSITION) %>% group_by(CHROMOSOME) %>% filter(!(row_number() == 1 | row_number() == n()))
  
  while (nrow(verlangend) != overhouden & nrow(nogNiet) != 0) {
    q <- apply(nogNiet, 1, function(x) {
      chrw <- verlangend[verlangend$CHROMOSOME == as.numeric(x['CHROMOSOME']),]$POSITION
      curw <- as.numeric(x['POSITION'])
      min(ifelse(chrw > curw, chrw - curw, curw - chrw))
    })
    q <- ifelse(q < 0, -q, q)
    verlangend <- rbind(verlangend, nogNiet[grep(max(q), q)[1],])
    nogNiet <- nogNiet[-grep(max(q), q)[1],]
  }
  minste_afstand <- verlangend %>% arrange(CHROMOSOME, POSITION) %>% group_by(CHROMOSOME) %>%
    mutate(verschil_voor = POSITION - lag(POSITION, default = NA),
           verschil_na = lead(POSITION, default = NA) - POSITION) %>%
    #mutate(verschil_voor = if_else(verschil_voor > 0, verschil_voor, -verschil_voor),
    #       verschil_voor = if_else(verschil_na > 0, verschil_na, -verschil_na)) %>%
    filter(min(if_else(!is.na(verschil_voor), verschil_voor, 1000000000L)) == verschil_voor |
             min(if_else(!is.na(verschil_na), verschil_na, 1000000000L)) == verschil_na) %>%
    filter(min(if_else(min(verschil_voor) == verschil_voor, as.integer(NA), verschil_voor),
               if_else(min(verschil_na) == verschil_na, as.integer(NA), verschil_na), na.rm = TRUE) == verschil_voor |
             min(if_else(min(verschil_voor) == verschil_voor, as.integer(NA), verschil_voor),
                 if_else(min(verschil_na) == verschil_na, as.integer(NA), verschil_na), na.rm = TRUE) == verschil_na) %>%
    ungroup() %>% filter(min(verschil_voor, verschil_na, na.rm = TRUE) == verschil_voor |
                           min(verschil_voor, verschil_na, na.rm = TRUE) == verschil_na)
  message("De kortste afstand tussen 2 mutaties op hetzelfde chromosoom is ", min(minste_afstand$verschil_voor, minste_afstand$verschil_na))
  return(verlangend)
}
Sys.time()
setwd("/data/david.noteborn/blast_output/100arbitrair/")
# neem het laatste opgeslagen fasta bestand
blasted <- file.info(paste0(list.files(pattern = "fasta")))
fasta.bestand <- rownames(blasted[with(blasted, order(mtime, decreasing = TRUE)), ][1,])
chrpos <- strsplit(sub("..$", "", unique(names(readDNAStringSet(fasta.bestand)))), ",")
posities <- data.frame(chromosome = as.numeric(mapply(`[`, chrpos, 1)),
                       position = as.numeric(mapply(`[`, chrpos, 2)))
if (!is.na(commandArgs(trailingOnly=TRUE)[1])) db = commandArgs(trailingOnly=TRUE)[1] else db = "/data/david.noteborn/acht.db"
eightnucleotide <- dbConnect(SQLite(), db)
dbWriteTable(eightnucleotide, "FILTERED_VALIDATE_FR", posities, overwrite = TRUE)
if ("EXULANS_VALID" %in% dbListTables(eightnucleotide)) dbRemoveTable(eightnucleotide, "EXULANS_VALID")
# inner join op gefilterde posities en exulans tabel
dbExecute(eightnucleotide, "CREATE TABLE IF NOT EXISTS EXULANS_VALID AS SELECT * FROM EXULANS INNER JOIN FILTERED_VALIDATE_FR ON EXULANS.POSITION = FILTERED_VALIDATE_FR.position AND EXULANS.CHROMOSOME = FILTERED_VALIDATE_FR.chromosome;")
exulans <- tbl(eightnucleotide, "EXULANS_VALID")
# pak SNPs
dieper <- exulans %>% collect()
# sla haplotypes op in losse variablen
dieper$GENOTYPE.LEFT <- mapply(`[`, strsplit(dieper$GENOTYPE_BP, "/"), 1)
dieper$GENOTYPE.RIGHT <- mapply(`[`, strsplit(dieper$GENOTYPE_BP, "/"), 2)
dieper$KEUZE <- paste(dieper$REFERENCE, dieper$ALTERNATIVE, sep = ",")
dieper %>% group_by(CHROMOSOME, POSITION) %>% summarise(n()) %>% ungroup() %>% summarise(n())
# groepeer op gelijke genotypes per SNP
# en haal homozygote SNPs weg
zoekterm <- dieper %>% group_by(CHROMOSOME, POSITION, GENOTYPE_BP, REFERENCE) %>%
  summarise(HOEVEEL_GENOTYPE = n(), DIST_N = min(DIST_N), DIST_P = min(DIST_P)) %>% group_by(CHROMOSOME, POSITION, REFERENCE) %>% summarise(verschillende = n_distinct(GENOTYPE_BP), DIST_N = min(DIST_N), DIST_P = min(DIST_P), records = sum(HOEVEEL_GENOTYPE, na.rm = TRUE), max_genotype = if_else(8L-sum(HOEVEEL_GENOTYPE, na.rm = TRUE) > max(HOEVEEL_GENOTYPE), 8L-sum(HOEVEEL_GENOTYPE, na.rm = TRUE), max(HOEVEEL_GENOTYPE)), alle_bases = paste0(GENOTYPE_BP, collapse = "/"))  %>% # hoeveel verschillende genotypes zijn er
  mutate(verschillende = if_else(records!=8L, verschillende+1L, verschillende), alle_bases = if_else(records!=8L, paste(alle_bases, REFERENCE, sep = "/"), alle_bases)) # haal homozygote weg hoeveel daarvan
zoekterm %>% ungroup() %>% summarise(n())

# aantal SNPs die niet in slechts 1 sample voorkomen
zoekterm %>% filter(verschillende > 1) %>% ungroup() %>% summarise(n())
# SNPs met 3 verschillende basen worden weggehaald uit zoekterm
zoekterm <- zoekterm[mapply(function(x) 3>length(unique(x)), strsplit(zoekterm$alle_bases, '/')),]
# tabel die het aantal genotypes/ hoe vaak het meest voorkomende genotype voorkomt bevat
diep <- zoekterm %>% filter(verschillende > 1) %>% group_by(verschillende, max_genotype) %>% summarise(aantal = n())
diep$`Meest
voorkomende
genotype` <- as.character(diep$max_genotype)
diep$verschillende <- as.character(diep$verschillende)
heterozygote <- zoekterm %>% filter(verschillende == 3) %>% collect()
geenzeven <- zoekterm %>% filter(verschillende == 2, !(max_genotype == 7 & verschillende == 2)) %>% collect()
zeven <- zoekterm %>% filter(verschillende > 1, (max_genotype == 7 & verschillende == 2)) %>% collect()

# volledig <- rbind(geenzeven[sample(1:nrow(geenzeven), ifelse(100-nrow(heterozygote) > 0, 100-nrow(heterozygote), 0)),], heterozygote[if (nrow(heterozygote)<100) TRUE else 1:207,])
volledig <- haalDichtstBijzijnsteWeg(rbind(heterozygote, geenzeven), 259)

# volledig <- rbind(zeven[sample(1:nrow(zeven), ifelse(300-nrow(volledig) > 0, 300-nrow(volledig), 0)),], volledig[if (nrow(volledig)<300) TRUE else 1:300,])
# maak het staafdiagram figuur
ggplot(diep, aes(verschillende, aantal)) + geom_col(aes(fill = `Meest
voorkomende
genotype`)) + xlab("Genotypen op SNP") + ylab("aantal")
ggsave("temp.png")
bot <- TGBot$new(token = "TOKEN")
bot$sendPhoto("temp.png", "Dit is de polyformiteit distributie van EXULANS", chat_id = 0)
unlink("temp.png")
# laat een rij zien
zeven[sample(1:nrow(zeven), 1),]
meta.data <- volledig %>% group_by(verschillende, max_genotype) %>% summarise(aantal = n())
setwd("~/SNP-files/")
# sla op in database, en bestand
write.csv(volledig, "PRIMER_DESIGNER_opvullend.csv")
dbWriteTable(eightnucleotide, "SELECTED_OPVULLEND", volledig[,c("CHROMOSOME", "POSITION")], overwrite = TRUE)
selected <- tbl(eightnucleotide, "SELECTED_OPVULLEND")
# haal dmv inner join alle informatie van de geselecteerde SNPs op
SNPs <- inner_join(exulans, selected, c(CHROMOSOME = "CHROMOSOME", POSITION = "POSITION")) %>% collect()
dbDisconnect(eightnucleotide)

SNPs <- SNPs[,-grep(":1", colnames(SNPs))]
SNPs$GENOTYPE <- SNPs$GENOTYPE_BP
# geef aan hoe vaak welk genotype voorkomt over de geselecteerde SNPs
table(SNPs$GENOTYPE_BP)
# vat de data samen tot 1 rij per SNP
beterSNPs <- SNPs %>% group_by(CHROMOSOME, POSITION) %>% summarise(average.quality = mean(QUALITY), diff_gt = paste(dplyr::first(REFERENCE), paste0(GENOTYPE_BP, collapse = "/"), sep = "/"), average.coverage = mean(COVERAGE), REFERENCE = dplyr::first(as.character(REFERENCE)))
o2n <- sub(".*/", "", read.csv("/data/david.noteborn/sample-enum.csv", col.names = c("ORGANISM", "NUMBER"), header = FALSE, stringsAsFactors = FALSE)$ORGANISM)
o2n <- o2n[!duplicated(o2n)]
beterSNPs[,o2n] <- beterSNPs$REFERENCE
beterSNPs$diff_gt <- mapply(function(x) paste0(unique(x), collapse = "/"), strsplit(beterSNPs$diff_gt, "/"))
ggplot(data.frame(table(beterSNPs$CHROMOSOME)), aes(Var1, Freq)) + geom_col()
ggsave("SNPchromOpvullend.png")
invisible(apply(SNPs, 1, function(x) beterSNPs[beterSNPs$CHROMOSOME==as.numeric(x["CHROMOSOME"])&beterSNPs$POSITION==as.numeric(x["POSITION"]), o2n[as.numeric(x['ORGANISM'])]] <<- sub("(.)/\\1", "\\1", x["GENOTYPE"])))
beterSNPs
setwd("/data/david.noteborn/blast_output/100arbitrair/")
# haal de sequenties op
# neem het nieuwste bestand
blasted <- file.info(paste0(list.files(pattern = "fasta")))
fasta.bestand <- rownames(blasted[with(blasted, order(mtime, decreasing = TRUE)), ][1,])
# lees het in
fasta <- readDNAStringSet(fasta.bestand)
q <- apply(beterSNPs, 1, function(x) {
  sel <- grep(paste(as.numeric(x["CHROMOSOME"]), as.numeric(x["POSITION"]), sep = ","), names(fasta))
  if (length(sel)!=0) {
    cat(sel)
    beterSNPs[as.numeric(x["CHROMOSOME"])==beterSNPs$CHROMOSOME&beterSNPs$POSITION==as.numeric(x["POSITION"]),"sequentie.voor"] <<- toString(fasta[sel[1]])
    beterSNPs[as.numeric(x["CHROMOSOME"])==beterSNPs$CHROMOSOME&beterSNPs$POSITION==as.numeric(x["POSITION"]),"sequentie.na"] <<- toString(fasta[sel[2]])
  }
})
setwd(paste0(Sys.getenv("HOME"), "/SNP-files/"))
beterSNPs <- beterSNPs[!is.na(beterSNPs$sequentie.voor),]
# maak plots die de verdeling van de SNPs laten zien
ggplot(beterSNPs, aes(CHROMOSOME, POSITION)) + geom_violin() + geom_jitter(height = 0, width = 0.1) + ggtitle("Neurotransmitter")
ggsave("neurotransmitter-verdeling-opvullend.png")
ggplot(beterSNPs, aes(TRUE, POSITION)) + geom_violin() + geom_dotplot(binaxis='y', stackdir='center') + ggtitle("Verdeling over posities")
ggsave("violin-verdeling-opvullend.png")
View(beterSNPs)
# sla de data op als csv
write.csv(beterSNPs, "SNP-opvullend.csv", row.names = FALSE, quote = FALSE)
# bekijk of (alle) individuele samples van elkaar kunnen worden gescheiden door een SNP (en welke)
combinaties <- combn(o2n, 2)
rownames(combinaties) <- c("eerste", "tweede")
colnames(combinaties) <- apply(combinaties, 2, function(x){
  paste0(head(beterSNPs[beterSNPs[,x['eerste']]!=beterSNPs[,x['tweede']]&!grepl("/", beterSNPs[,x['eerste']][[1]])&!grepl("/", beterSNPs[,x['tweede']][[1]]),c("CHROMOSOME", "POSITION")], 1), collapse = "-")
  })
combinaties
# formaat voor primer ontwerp...
# (weliswaar zonder gen/GO data)
writeLines(paste0("CHR", beterSNPs$CHROMOSOME, "_", beterSNPs$POSITION, "\t", beterSNPs$sequentie.voor, "{", beterSNPs$diff_gt, "}", beterSNPs$sequentie.na), "SNP-opvullend.txt")
# write.table(beterSNPs[,c("CHROMOSOME", "POSITION")], "verwerkSNPpos.ssv", sep = ",", row.names = FALSE)
# sed -nE '1!s/([0-9]+),([0-9]+),.*"([^"]+)","([^"]+)"/>\1-\2 voor\n\3\n>\1-\2 na\n\4/p' SNP_V1.csv > SNP_V1.fasta
# sed -nE '1!s/([0-9]+),([0-9]+),.*,([^,]+),([^,]+)$/>\1-\2 voor\n\3\n>\1-\2 na\n\4/p' SNP_V2.csv > SNP_V2.fasta
