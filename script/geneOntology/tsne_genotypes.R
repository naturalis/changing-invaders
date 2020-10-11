#!/usr/bin/env Rscript
# genotype distance plot
# changeing invaders
# cut -d, -f7-14 SNP.csv|sed '1s/_[^,]*//g'|tr , \\t|awk '{print $1"\t"$4"\t"$2"\t"$3"\t"$5"\t"$6"\t"$7"\t"$8}'
# setwd(Sys.glob("~/Doc*/Nat*/gene*-ont*"))
setwd(Sys.glob("gene*-ont*"))
library(ggplot2)
library(ggrepel)
library(Rtsne)

answer <- menu(list.files(pattern = "*\\.bgt"), graphics = TRUE, "Choose a better genotype file")
if (answer != 0) {
	answer <- list.files(pattern = "*\\.bgt")[answer]
	genotypes <- read.table(answer, TRUE, stringsAsFactors = TRUE)
	tsne.outcome <- Rtsne(t(genotypes), dims = 3, perplexity = 2)
	rownames(tsne.outcome$Y) <- colnames(genotypes)
	dim.2 <- as.data.frame(tsne.outcome$Y)
	dim.2$sample <- rownames(dim.2)
	dim.2$Area <- "Unknown"
	dim.2[dim.2$sample %in% c("L0235", "L0234", "C0910", "R6750", "R7129"),]$Area <- "Mainland"
	dim.2[dim.2$sample %in% c("GMI.4", "R14018"),]$Area <- "Island"
	dim.2[dim.2$sample %in% c("P0041"),]$Area <- "Semi-Mainland"
	ggplot(dim.2, aes(V1, V2)) + geom_point() + geom_label_repel(aes(label = sample)) +
	  xlab("t-SNE dimension 1") + ylab("t-SNE dimension 2") +
	  ggtitle(paste("tSNE analysis over all", sub("\\.bgt$", "", answer), " coding SNPs"), subtitle = "Discarding all synonymous coding SNPs")
	# awk '$4==$6&&$4!=$1&&$4!=$2&&$4!=$3&&$4!=$5&&$4!=$7&&$4!=$8{print}' ASM.gt
	ggsave(sub("\\.bgt$", "_tsne.png", answer))
	save(tsne.outcome, file = sub("\\.bgt$", ".tsne", answer))
}
