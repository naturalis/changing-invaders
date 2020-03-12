#!/usr/bin/env Rscript
# controlleer op sginificante groepen
# changeing invaders
# cut -d, -f7-14 SNP.csv|sed '1s/_[^,]*//g'|tr , \\t|awk '{print $1"\t"$4"\t"$2"\t"$3"\t"$5"\t"$6"\t"$7"\t"$8}'
setwd("~/Documenten/Naturalis/genen-ontologie/")
library(ggplot2)
library(ggrepel)

antwoord <- menu(list.files(pattern = "*.gt"), graphics = TRUE, "Kies een genotype bestand")
if (antwoord != 0) {
	ASM <- read.table(list.files(pattern = "*.gt")[antwoord], TRUE, stringsAsFactors = TRUE)
	massa <- MASS::mca(as.data.frame(t(ASM)))
	dim.2 <- as.data.frame(massa$fs)
	dim.2$sample <- rownames(dim.2)
	ggplot(dim.2, aes(`1`, `2`)) + geom_point() + geom_label_repel(aes(label = sample)) + xlab("MCA dimension 1") + ylab("MCA dimension 2") + ggtitle("Multiple Correspondence Analysis over all Anatomical\nStructure Morphogenesis coding SNPs", subtitle = "Discarding all sysnonymous coding SNPs")
	# awk '$4==$6&&$4!=$1&&$4!=$2&&$4!=$3&&$4!=$5&&$4!=$7&&$4!=$8{print}' ASM.gt
  ggsave(sub(".gt$", "_msa.png", list.files(pattern = "*.gt")[antwoord]))
  save(massa, file = sub(".gt$", ".mca", list.files(pattern = "*.gt")[antwoord]))
}
