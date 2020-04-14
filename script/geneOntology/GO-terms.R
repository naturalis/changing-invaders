# GO-terms
# doe een Go term analyse
# changing invaders
# by david
# BiocManager::install(c("limma", "GO.db"))
suppressMessages(library(limma))
suppressMessages(library(biomaRt))
suppressMessages(library(GO.db))
# setwd("gen-ontologie/")
if (!is.na(commandArgs(trailingOnly=TRUE)[1])) bestand = commandArgs(trailingOnly=TRUE)[1] else bestand = "hoevaakGenMetExon.csv"
hoevaak_gen <- read.table(bestand, header = TRUE, row.names = 1)
ensembl = useDataset("rnorvegicus_gene_ensembl", mart = useMart("ensembl"))
ontology_gen <- getBM(attributes = c('ensembl_gene_id', 'entrezgene_id'),
                      values = rownames(hoevaak_gen), mart = ensembl)
ontology_sel_gen <- ontology_gen[!is.na(ontology_gen$entrezgene_id),]
head(ontology_sel_gen)
hoevaak_gen$ensembl_gene_id <- rownames(hoevaak_gen)
hoevaak_overview <- dplyr::inner_join(hoevaak_gen, ontology_sel_gen)
hoevaak_overview <- hoevaak_overview[!duplicated(hoevaak_overview$entrezgene_id),]
rownames(hoevaak_overview) <- hoevaak_overview$entrezgene_id
hoevaak <- as.numeric(Reduce(c, apply(hoevaak_overview, 1, function(x) rep(x['entrezgene_id'], x['hoevaak']))))
#hoevaak <- hoevaak_overview[,c("hoevaak")]
#names(hoevaak) <- hoevaak_overview$entrezgene_id

go.analyse <- goana(as.character(hoevaak), species = "Rn")

View(go.analyse)
write.csv(go.analyse, 'go-termen.csv')



BiocManager::install("clusterProfiler")
require(clusterProfiler)
data(geneList, package="DOSE")
de <- names(geneList)[abs(geneList) > 2]
bp <- enrichGO(as.character(hoevaak), 'org.Rn.eg.db', ont="MF")
head(bp, n = 10)
enrichMap(bp)
bp2 <- simplify(bp, cutoff=0.7, by="p.adjust", select_fun=min)
enrichMap(bp2)
