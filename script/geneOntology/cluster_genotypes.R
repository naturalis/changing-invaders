#!/usr/bin/env Rscript
# changeing invaders
# make MCA for genotypes
# by david
# cut -d, -f7-14 SNP.csv|sed '1s/_[^,]*//g'|tr , \\t|awk '{print $1"\t"$4"\t"$2"\t"$3"\t"$5"\t"$6"\t"$7"\t"$8}'
# ggplot voor plotting of the MCA
library(ggplot2)
# ggrepel so labels wont overlap and reading of the samplenames is imposibble
library(ggrepel)
if (length(commandArgs(trailingOnly=T))>0) verwerken <- commandArgs(trailingOnly=T) else {
	gt_bestanden <- list.files(pattern = "*.gt")
	# give if possible a graphical menu with all .gt files, where the user can choose one or more for the MCA
	verwerken <- select.list(gt_bestanden, multiple = TRUE, title = "Kies een genotype bestand")
}
# for every chosen gt file
for (genotypes in verwerken) {
	# read the gt file
	ASM <- read.table(genotypes, TRUE, stringsAsFactors = TRUE)
	# execute the MCA
	massa <- MASS::mca(as.data.frame(t(ASM)))
	# get the table with the positions
	dim.2 <- as.data.frame(massa$fs)
	dim.2$sample <- rownames(dim.2)
	# plot the positions
	ggplot(dim.2, aes(`1`, `2`)) + geom_point() + geom_label_repel(aes(label = sample)) + xlab("MCA dimension 1") + ylab("MCA dimension 2") +
		ggtitle(paste0("Multiple Correspondence Analysis over all ", sub(".gt$", "", genotypes), " SNPs"), subtitle = "Discarding all sysnonymous coding SNPs")
	# awk '$4==$6&&$4!=$1&&$4!=$2&&$4!=$3&&$4!=$5&&$4!=$7&&$4!=$8{print}' ASM.gt
	# save the plot
	ggsave(sub(".gt$", "_msa.png", genotypes))
	# save the MCA data (so the plotting can be done again without repeating the analysis)
	save(massa, file = sub(".gt$", ".mca", genotypes))
}
