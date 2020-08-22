#!/usr/bin/env Rscript
# changing invaders
# by david
# combine PCA created in one plot
# cut -d, -f7-14 SNP.csv|sed '1s/_[^,]*//g'|tr , \\t|awk '{print $1"\t"$4"\t"$2"\t"$3"\t"$5"\t"$6"\t"$7"\t"$8}'
# ggplot for plotting of the PCA
library(ggplot2)
# ggrepel so labels will not overlap and reading of the sample names becomes impossible
library(ggrepel)
# patchwork so we can + plots together
library(patchwork)
if (length(commandArgs(trailingOnly=T))>0) process <- commandArgs(trailingOnly=T) else {
	pca_files <- list.files(pattern = "*.pca$")
	# give if possible a graphical menu with all .gt files, where the user can choose one or more for the plot
	process <- select.list(pca_files, multiple = TRUE, title = "Choose a PCA R data file")
	if (length(process)==0) process <- pca_files
}
to.plot <- list()
first.run <- TRUE
# for every chosen pca file
genotypes <- rev(process)
for (genotypes in rev(process)) {
	# read the gt file
	value.name <- load(genotypes)
	# get the object that belongs to the variable name
	pca.outcome <- get(value.name)
	# if the R object was already known as pca.outcome removing it will result in removing the data
	if (value.name != "pca.outcome") rm(list = value.name)
	# get the table with the positions
	dim.2 <- as.data.frame(pca.outcome$x)
	dim.2$sample <- rownames(dim.2)
	dim.2$Area <- "Unknown"
	dim.2[dim.2$sample %in% c("L0235", "L0234", "C0910", "R6750", "R7129"),]$Area <- "Mainland"
	dim.2[dim.2$sample %in% c("GMI.4", "R14018"),]$Area <- "Island"
	dim.2[dim.2$sample %in% c("P0041"),]$Area <- "Semi-Mainland"

	# plot the positions
	created.plot <- ggplot(dim.2, aes(PC1, PC2)) + geom_point() + geom_label_repel(aes(label = sample, fill = Area)) +
		xlab("PCA dimension 1") + ylab("PCA dimension 2") + scale_fill_manual(breaks = c("Island", "Semi-Mainland", "Mainland"), values=c("Blue", "Yellow", "darkGreen")) + theme(legend.position = "none")
	if (first.run) {
		created.plot <- created.plot + ggtitle(paste0("Principal Components Analysis over all ", sub(".pca$", "", genotypes), " SNPs"),
											   subtitle = "Discarding all synonymous coding SNPs")
		first.run <- FALSE
	}
	if (!process[1]==genotypes) created.plot <- created.plot + theme(axis.title.x = element_blank(), legend.position = c(0.9, 0.25))
	to.plot[[sub("\\.pca$", "", genotypes)]] <- created.plot
	# awk '$4==$6&&$4!=$1&&$4!=$2&&$4!=$3&&$4!=$5&&$4!=$7&&$4!=$8{print}' ASM.gt
}
Reduce(`/`, to.plot) + plot_annotation(tag_levels = 'A')
ggsave("PCA_report.png", width = 7, height = 14)
