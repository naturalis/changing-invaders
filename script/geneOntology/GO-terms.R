# GO-terms
# changing invaders
# execute a GO-term analysis
# by david
# BiocManager::install(c("limma", "GO.db", "clusterProfiler"))
suppressMessages(library(clusterProfiler))
suppressMessages(library(limma))
suppressMessages(library(biomaRt))
suppressMessages(library(GO.db))
# setwd("~/gene-ontology/")
if (!is.na(commandArgs(trailingOnly=TRUE)[1])) howManyFile = commandArgs(trailingOnly=TRUE)[1] else howManyFile = "amountGeneWithExon.csv"
amount_gene <- read.table(howManyFile, header = TRUE, row.names = 1)
ensembl = useDataset("rnorvegicus_gene_ensembl", mart = useMart("ensembl"))
ontology_gene <- getBM(attributes = c('ensembl_gene_id', 'entrezgene_id'),
                      values = rownames(amount_gene), mart = ensembl)
ontology_sel_gene <- ontology_gene[!is.na(ontology_gene$entrezgene_id),]
head(ontology_sel_gene)
amount_gene$ensembl_gene_id <- rownames(amount_gene)
amount_overview <- dplyr::inner_join(amount_gene, ontology_sel_gene)
amount_overview <- amount_overview[!duplicated(amount_overview$entrezgene_id),]
rownames(amount_overview) <- amount_overview$entrezgene_id
amount <- as.numeric(Reduce(c, apply(amount_overview, 1, function(x) rep(x['entrezgene_id'], x['amount']))))
#amount <- amount_overview[,c("amount")]
#names(amount) <- amount_overview$entrezgene_id

go.analysis <- goana(as.character(amount), species = "Rn")

View(go.analysis)
write.csv(go.analysis, 'go-terms.csv')


data(geneList, package="DOSE")
de <- names(geneList)[abs(geneList) > 2]
bp <- enrichGO(as.character(amount), 'org.Rn.eg.db', ont="BP")
head(bp, n = 10)
enrichMap(bp)
bp2 <- simplify(bp, cutoff=0.7, by="p.adjust", select_fun=min)
enrichMap(bp2)
