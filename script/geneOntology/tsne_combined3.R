#!/usr/bin/env Rscript
# changing invaders
# by david
# combine t-SNE created in one 3d plot
# the script requires montage from imagemagic and ffmpeg program installed
# cut -d, -f7-14 SNP.csv|sed '1s/_[^,]*//g'|tr , \\t|awk '{print $1"\t"$4"\t"$2"\t"$3"\t"$5"\t"$6"\t"$7"\t"$8}'
# ggplot3d for plotting of the 3d t-SNE
# devtools::install_github("AckerDWM/gg3D")
library(gg3D)
# patchwork so we can + plots together
library(patchwork)
if (length(commandArgs(trailingOnly=T))>0) process <- commandArgs(trailingOnly=T) else {
	tsne_files <- list.files(pattern = "*.tsne$")
	# give if possible a graphical menu with all .gt files, where the user can choose one or more for the plot
	process <- select.list(tsne_files, multiple = TRUE, title = "Choose a t-SNE R data file")
	if (length(process)==0) process <- tsne_files
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
		tsne.outcome <- get(value.name)
		# if the R object was already known as tsne.outcome removing it will result in removing the data
		if (value.name != "tsne.outcome") rm(list = value.name)
		# get the table with the positions
		dim.3 <- as.data.frame(tsne.outcome$Y)
		dim.3$sample <- rownames(dim.3)
		dim.3$Area <- "Unknown"
		dim.3[dim.3$sample %in% c("L0235", "L0234", "C0910", "R6750", "R7129"),]$Area <- "Mainland"
		dim.3[dim.3$sample %in% c("GMI.4", "R14018"),]$Area <- "Island"
		dim.3[dim.3$sample %in% c("P0041"),]$Area <- "Semi-Mainland"

		# plot the positions
		angle <- if (direction=="left") c(135 + diff_from_center, 20) else c(135 - diff_from_center, 20)
		created.plot <- ggplot(dim.3, aes(V1, V2, z = V3)) +
			stat_3D(geom = "label", aes(x = V1, y = V2, z = V3, label = sample, fill = Area), theta= angle[1], phi = angle[2]) +
			xlab("t-SNE dimension 1") + ylab("t-SNE dimension 2") + theme_void() +
			scale_fill_manual(breaks = c("Island", "Semi-Mainland", "Mainland"), values=c("Blue", "Yellow", "darkGreen")) +
			axes_3D(theta = angle[1], phi = angle[2])
		created.plot
		if (first.run) {
			created.plot <- created.plot + ggtitle(paste0("tSNE analysis over all ", sub(".tsne$", "", genotypes), " SNPs"),
												   subtitle = "Discarding all sysnonymous coding SNPs")
			first.run <- FALSE
		}
		if (!process[1]==genotypes) created.plot <- created.plot + theme(axis.title.x = element_blank(), legend.position = c(0.9, 0.25))
		if (direction== "left")to.plot.left[[ sub("\\.tsne$", "", genotypes)]] <- created.plot
		if (direction=="right")to.plot.right[[sub("\\.tsne$", "", genotypes)]] <- created.plot
		# awk '$4==$6&&$4!=$1&&$4!=$2&&$4!=$3&&$4!=$5&&$4!=$7&&$4!=$8{print}' ASM.gt
	}
}
file.remove(list.files(pattern = "t-SNE3_*"))
ggsave("t-SNE3_intermediate_report_left.png", plot = Reduce(`/`, to.plot.left) + plot_annotation(tag_levels = 'A'), width = 7, height = 14)
ggsave("t-SNE3_intermediate_report_right.png", plot =Reduce(`/`, to.plot.right) +plot_annotation(tag_levels = 'A'), width = 7, height = 14)
system("montage -mode concatenate -tile 2x1 $(ls t-SNE3_intermediate_report_*|tac) t-SNE3_intermediate_report.png")
system("ffmpeg -y -loglevel quiet -i t-SNE3_intermediate_report.png -vf stereo3d=sbs2l:arcd t-SNE3_report.png")
file.remove(list.files(pattern = "t-SNE3_intermediate_*"))
system("showimage t-SNE3_report.png")
