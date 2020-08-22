#!/usr/bin/env Rscript
# changing invaders
# by david
# make MCA for genotypes
# cut -d, -f7-14 SNP.csv|sed '1s/_[^,]*//g'|tr , \\t|awk '{print $1"\t"$4"\t"$2"\t"$3"\t"$5"\t"$6"\t"$7"\t"$8}'
# ggplot for plotting of the MCA
library(ggplot2)
# ggrepel so labels will not overlap and reading of the samplenames becomes impossible
library(ggrepel)
if (length(commandArgs(trailingOnly=T))>0) process <- commandArgs(trailingOnly=T) else {
	gt_files <- list.files(pattern = "*.gt$")
	# give if possible a graphical menu with all .gt files, where the user can choose one or more for the MCA
	process <- select.list(gt_files, multiple = TRUE, title = "Choose a genotype file")
}
# for every chosen gt file
for (genotypes in process) {
	# read the gt file
	ASM <- read.table(genotypes, TRUE, stringsAsFactors = TRUE)
	# execute the MCA
	massa <- MASS::mca(as.data.frame(t(ASM), stringsAsFactors = TRUE))
	# get the table with the positions
	dim.2 <- as.data.frame(massa$fs)
	dim.2$sample <- rownames(dim.2)
	dim.2$Area <- "Unknown"
	dim.2[dim.2$sample %in% c("L0235", "L0234", "C0910", "R6750", "R7129"),]$Area <- "Mainland"
	dim.2[dim.2$sample %in% c("GMI.4", "R14018"),]$Area <- "Island"
	dim.2[dim.2$sample %in% c("P0041"),]$Area <- "Semi-Mainland"

	# plot the positions
	ggplot(dim.2, aes(`1`, `2`)) + geom_point() + geom_label_repel(aes(label = sample)) + xlab("MCA dimension 1") + ylab("MCA dimension 2") +
		ggtitle(paste0("Multiple Correspondence Analysis over all ", sub(".gt$", "", genotypes), " SNPs"), subtitle = "Discarding all synonymous coding SNPs")
	# awk '$4==$6&&$4!=$1&&$4!=$2&&$4!=$3&&$4!=$5&&$4!=$7&&$4!=$8{print}' ASM.gt
	# save the plot
	ggsave(sub(".gt$", "_mca.png", genotypes))
	# save the MCA data (so the plotting can be done again without repeating the analysis)
	save(massa, file = sub(".gt$", ".mca", genotypes))
}
