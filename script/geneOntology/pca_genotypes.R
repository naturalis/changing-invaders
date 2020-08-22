#!/usr/bin/env Rscript
# controlleer op sginificante groepen
# changeing invaders
# cut -d, -f7-14 SNP.csv|sed '1s/_[^,]*//g'|tr , \\t|awk '{print $1"\t"$4"\t"$2"\t"$3"\t"$5"\t"$6"\t"$7"\t"$8}'
# setwd(Sys.glob("~/Doc*/Nat*/gene*-ont*"))
setwd(Sys.glob("gene*-ont*"))
library(ggplot2)
library(ggrepel)

answer <- menu(list.files(pattern = "*\\.bgt"), graphics = TRUE, "Choose a file")
if (answer != 0) {
  answer <- list.files(pattern = "*\\.bgt")[answer]
	genotypes <- read.table(answer, TRUE, stringsAsFactors = TRUE)
	pca.outcome <- prcomp(t(genotypes), center = TRUE)
	dim.2 <- as.data.frame(pca.outcome$x[,1:2])
	dim.2$sample <- rownames(dim.2)
	dim.2$Area <- "Unknown"
	dim.2[dim.2$sample %in% c("L0235", "L0234", "C0910", "R6750", "R7129"),]$Area <- "Mainland"
	dim.2[dim.2$sample %in% c("GMI.4", "R14018"),]$Area <- "Island"
	dim.2[dim.2$sample %in% c("P0041"),]$Area <- "Semi-Mainland"
	ggplot(dim.2, aes(PC1, PC2)) + geom_point() + geom_label_repel(aes(label = sample)) +
	  xlab("PCA dimension 1") + ylab("PCA dimension 2") +
	  ggtitle(paste("Principial Components Analysis over all", sub("\\.bgt$", "", answer), " coding SNPs"), subtitle = "Discarding all synonymous coding SNPs")
	# awk '$4==$6&&$4!=$1&&$4!=$2&&$4!=$3&&$4!=$5&&$4!=$7&&$4!=$8{print}' ASM.gt
  ggsave(sub("\\.bgt$", "_pca.png", answer))
  save(pca.outcome, file = sub("\\.bgt$", ".pca", answer))
}
