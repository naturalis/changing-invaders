#!/usr/bin/env Rscript
# changing invaders
# by david
# combine PCA created in one 3d plot
# the script requires montage from imagemagic and ffmpeg program installed
# cut -d, -f7-14 SNP.csv|sed '1s/_[^,]*//g'|tr , \\t|awk '{print $1"\t"$4"\t"$2"\t"$3"\t"$5"\t"$6"\t"$7"\t"$8}'
# ggplot3d for plotting of the 3d PCA
# devtools::install_github("AckerDWM/gg3D")
library(gg3D)
# ggrepel so labels will not overlap and reading of the sample names becomes impossible
library(ggrepel)
# patchwork so we can + plots together
library(patchwork)
if (length(commandArgs(trailingOnly=T))>0) process <- commandArgs(trailingOnly=T) else {
	pca_files <- list.files(pattern = "*.pca$")
	# give if possible a graphical menu with all .gt files, where the user can choose one or more for the plot
	process <- select.list(pca_files, multiple = TRUE, title = "Choose a pca R data file")
	if (length(process)==0) process <- pca_files
}
1
to.plot.left <- list()
to.plot.right <- list()
diff_from_center = 4
# for every chosen gt file
for (direction in c("left", "right")) {
	first.run <- TRUE
	for (genotypes in rev(process)) {
		# read the gt file
		value.name <- load(genotypes)
		# get the object that belongs to the variable name
		pca.outcome <- get(value.name)
		# if the R object was already known as pca.outcome removing it will result in removing the data
		if (value.name != "pca.outcome") rm(list = value.name)
		# get the table with the positions
		dim.3 <- as.data.frame(pca.outcome$x)
		dim.3$sample <- rownames(dim.3)
		dim.3$Area <- "Unknown"
		dim.3[dim.3$sample %in% c("L0235", "L0234", "C0910", "R6750", "R7129"),]$Area <- "Mainland"
		dim.3[dim.3$sample %in% c("GMI.4", "R14018"),]$Area <- "Island"
		dim.3[dim.3$sample %in% c("P0041"),]$Area <- "Semi-Mainland"

		# plot the positions
		angle <- if (direction=="left") c(135 + diff_from_center, 20) else c(135 - diff_from_center, 20)
		created.plot <- ggplot(dim.3, aes(PC1, PC2, z = PC3)) +
			stat_3D(geom = "label_repel", aes(x = PC1, y = PC2, z = PC3, label = sample, fill = Area), theta= angle[1], phi = angle[2]) +
			xlab("PCA dimension 1") + ylab("PCA dimension 2") + theme_void() +
			scale_fill_manual(breaks = c("Island", "Semi-Mainland", "Mainland"), values=c("Blue", "Yellow", "darkGreen")) +
			axes_3D(theta = angle[1], phi = angle[2]) + stat_3D(theta = angle[1], phi = angle[2])
		created.plot
		if (first.run) {
			created.plot <- created.plot + ggtitle(paste0("Multiple Correspondence Analysis over all ", sub(".pca$", "", genotypes), " SNPs"),
												   subtitle = "Discarding all synonymous coding SNPs")
			first.run <- FALSE
		}
		if (!process[1]==genotypes) created.plot <- created.plot + theme(axis.title.x = element_blank(), legend.position = c(0.9, 0.25))
		if (direction== "left")to.plot.left[[ sub("\\.pca$", "", genotypes)]] <- created.plot
		if (direction=="right")to.plot.right[[sub("\\.pca$", "", genotypes)]] <- created.plot
		# awk '$4==$6&&$4!=$1&&$4!=$2&&$4!=$3&&$4!=$5&&$4!=$7&&$4!=$8{print}' ASM.gt
	}
}
file.remove(list.files(pattern = "PCA3_*"))
ggsave("PCA3_intermediate_report_left.png", plot = Reduce(`/`, to.plot.left) + plot_annotation(tag_levels = 'A'), width = 7, height = 14)
ggsave("PCA3_intermediate_report_right.png", plot =Reduce(`/`, to.plot.right) +plot_annotation(tag_levels = 'A'), width = 7, height = 14)
system("montage -mode concatenate -tile 2x1 $(ls PCA3_intermediate_report_*|tac) PCA3_intermediate_report.png")
system("ffmpeg -y -loglevel quiet -i PCA3_intermediate_report.png -vf stereo3d=sbs2l:arcd PCA3_report.png")
file.remove(list.files(pattern = "PCA3_intermediate_*"))
system("showimage PCA3_report.png")
