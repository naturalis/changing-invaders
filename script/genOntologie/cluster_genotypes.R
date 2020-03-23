#!/usr/bin/env Rscript
# maak MCA voor genotypes
# changeing invaders
# by david
# cut -d, -f7-14 SNP.csv|sed '1s/_[^,]*//g'|tr , \\t|awk '{print $1"\t"$4"\t"$2"\t"$3"\t"$5"\t"$6"\t"$7"\t"$8}'
# ggplot voor het plotten van de MCA
library(ggplot2)
# ggrepel zodat labels niet op elkaar komen te zitten en het lezen van de samplenamen onmogelijk wordt
library(ggrepel)
if (length(commandArgs(trailingOnly=T))>0) verwerken <- commandArgs(trailingOnly=T) else {
	gt_bestanden <- list.files(pattern = "*.gt")
	# geeft indien mogelijk een grafisch menu met alle .gt bestanden, waaruit de gebruiker een of meerdere voor de MCA kan kiezen
	verwerken <- select.list(gt_bestanden, multiple = TRUE, title = "Kies een genotype bestand")
}
# voor ieder gekozen gt bestand
for (genotypes in verwerken) {
	# lees het gt bestand in
	ASM <- read.table(genotypes, TRUE, stringsAsFactors = TRUE)
	# voer de MCA uit
	massa <- MASS::mca(as.data.frame(t(ASM)))
	# neem de tabel met posities
	dim.2 <- as.data.frame(massa$fs)
	dim.2$sample <- rownames(dim.2)
	# plot de posities
	ggplot(dim.2, aes(`1`, `2`)) + geom_point() + geom_label_repel(aes(label = sample)) + xlab("MCA dimension 1") + ylab("MCA dimension 2") +
		ggtitle(paste0("Multiple Correspondence Analysis over alle ", sub(".gt$", "", genotypes), " SNPs"), subtitle = "Discarding all sysnonymous coding SNPs")
	# awk '$4==$6&&$4!=$1&&$4!=$2&&$4!=$3&&$4!=$5&&$4!=$7&&$4!=$8{print}' ASM.gt
	# sla plot op
	ggsave(sub(".gt$", "_msa.png", genotypes))
	# sla MCA data op (zodat opnieuw geplot kan worden zonder hele analyse opnieuw te doen)
	save(massa, file = sub(".gt$", ".mca", genotypes))
}
