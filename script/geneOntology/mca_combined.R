#!/usr/bin/env Rscript
# changing invaders
# by david
# combine MCA created in one plot
# cut -d, -f7-14 SNP.csv|sed '1s/_[^,]*//g'|tr , \\t|awk '{print $1"\t"$4"\t"$2"\t"$3"\t"$5"\t"$6"\t"$7"\t"$8}'
# ggplot for plotting of the MCA
library(ggplot2)
# ggrepel so labels will not overlap and reading of the sample names becomes impossible
library(ggrepel)
# patchwork so we can + plots together
library(patchwork)
if (length(commandArgs(trailingOnly=T))>0) process <- commandArgs(trailingOnly=T) else {
	mca_files <- list.files(pattern = "*.mca")
	# give if possible a graphical menu with all .gt files, where the user can choose one or more for the plot
	process <- select.list(mca_files, multiple = TRUE, title = "Choose a genotype file")
}
to.plot <- list()
first.run <- TRUE
# for every chosen gt file
for (genotypes in rev(process)) {
	# read the gt file
	value.name <- load(genotypes)
	# get the object that belongs to the variable name
	massa <- get(value.name)
	# if the R object was already known as massa removing it will result in removing the data
	if (value.name != "massa") rm(list = value.name)
	# get the table with the positions
	dim.2 <- as.data.frame(massa$fs)
	dim.2$sample <- rownames(dim.2)
	# plot the positions
	created.plot <- ggplot(dim.2, aes(`1`, `2`)) + geom_point() + geom_label_repel(aes(label = sample)) +
		xlab("MCA dimension 1") + ylab("MCA dimension 2")
	if (first.run) {
		created.plot <- created.plot + ggtitle(paste0("Multiple Correspondence Analysis over all ", sub(".mca$", "", genotypes), " SNPs"),
											   subtitle = "Discarding all sysnonymous coding SNPs")
		first.run <- FALSE
	}
	if (!process[1]==genotypes) created.plot <- created.plot + theme(axis.title.x = element_blank())
	to.plot[[sub("\\.mca$", "", genotypes)]] <- created.plot
	# awk '$4==$6&&$4!=$1&&$4!=$2&&$4!=$3&&$4!=$5&&$4!=$7&&$4!=$8{print}' ASM.gt
}
Reduce(`/`, to.plot) + plot_annotation(tag_levels = 'A')
ggsave("MCA_report.png", width = 7, height = 14)
