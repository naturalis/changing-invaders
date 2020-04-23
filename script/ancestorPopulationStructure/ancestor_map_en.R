#!/usr/bin/env Rscript
# changing invaders
# by david
# barplot anchestor output
library(ggmap, quietly = TRUE)
library(ggrepel)
library(dplyr, warn.conflicts = FALSE)
library(scatterpie)
if (length(commandArgs(trailingOnly = TRUE)) == 0) {
	Q.files <- file.info(paste0(list.files(pattern = "\\.(mean)?Q$")))
	Q.files <- rownames(Q.files[with(Q.files, order(mtime, decreasing = TRUE)), ][1,])
	Q.files <- rownames(file.info(paste0(list.files(pattern = sub("(.[^.]+){2}$", "\\.[0-9]+.*Q$", Q.files)))))
} else Q.files <- commandArgs(trailingOnly = TRUE)

lijst <- "GMI-4 -> Great Mercuri Island, New Zealand North Island, lt -36.6155, long. 175.7938
L0234 -> Laos, Champasak province, lt 15.20989, long. 105.7906
C0910 -> Cambodia, Pursat province lat. 12.57472, long. 104.2075
L0235 -> Laos, Champasak province, lat. 15.20989, long. 105.7906
P0041 -> Philippines, Tarlac, lat. 15.43469, long. 120.4959
R6750 -> Thailand, Prachuap-Khiri-Khan province, lat. 11.78622 long. 99.648933
R7129 -> Thailand, Tak province, lat. 16.80463, long. 98.73463
R14018-> Doubtful Sound, New Zealand South Island, lat. -45.3502, long. 167.0018"
sample_table <- as.data.frame(Reduce(rbind, strsplit(unlist(strsplit(lijst, "\n")), " ?-> |,? la?t\\.? |,? long. ")), stringsAsFactors = FALSE)
colnames(sample_table) <- c("SAMPLE", "LOCATIE", "LATITUDE", "LONGDITUDE")
rownames(sample_table) <- sample_table$SAMPLE
sample_table$LATITUDE <- as.numeric(sample_table$LATITUDE)
sample_table$LONGDITUDE <- as.numeric(sample_table$LONGDITUDE)
if (file.exists("~/structuur/aus_map.rdata")) load("~/structuur/aus_map.rdata") else {
	aus_map <- get_stamenmap(c(min(sample_table$LONGDITUDE) - 1, min(sample_table$LATITUDE) - 1, max(sample_table$LONGDITUDE) + 1, max(sample_table$LATITUDE) + 1), 5)
	save(aus_map, file = "~/structuur/aus_map.rdata")
}
for (Q.file in Q.files) {
	tbl_orig <- read.table(Q.file)
	tbl <- round(tbl_orig, digits = 2)
	rownames(tbl) <- sub("_.*", "", read.table("~/structuur/merge8.fam")$V2)
	colnames(tbl) <- as.character(1:ncol(tbl))
	# the sample name in the plot is the sort (up to the _) version within the fam file
	tbl$SAMPLE <- sub("_.*", "", read.table("~/structuur/merge8.fam")$V2)
	sub("(([1-9]+)[0-9]?\\b)", "(aanname: \\1 voorouders)", sub("(admixt|struct)", "\\1ure", gsub("\\.|-", " ", sub("\\.(mean)?Q$", "", Q.file))))
	nanchestors <- as.numeric(rev(strsplit(Q.file, "\\.")[[1]])[2])

	# create a long table with the groups
	better_table <- full_join(tabel, tidyr::pivot_longer(tbl, c(as.character(1:(ncol(tbl) - 1))), "groep", values_to = "kans"), "SAMPLE")
	# store the most apparent group
	table_v <- full_join(tabel, better_table %>% group_by(SAMPLE) %>% summarise(groep = groep[kans == max(kans)]), "SAMPLE")
	# if the long table explains that a group makes up about 0.999 part of an organism
	# make is_1 true, so we wont put there a cirkeldiagram
	table_v <- full_join(better_table %>% mutate(rond = round(kans, 2)) %>% mutate(is_1 = (rond == 0 | rond == 1)) %>% group_by(SAMPLE) %>% summarise(is_1 = all(is_1)), table_v, "SAMPLE")
	# give tbl more properties
	tbl <- full_join(table_v %>% select(LATITUDE, LONGDITUDE, SAMPLE, is_1), tbl, "SAMPLE")
	# get the map
	ggmap(aus_map) + geom_point(aes(LONGDITUDE, LATITUDE), data = table_v) + geom_scatterpie(aes(LONGDITUDE, ifelse(!is_1, LATITUDE, NA)), tbl, na.rm = TRUE, cols = as.character(1:(ncol(tbl) - 4))) + geom_label_repel(aes(LONGDITUDE, LATITUDE, label = SAMPLE, fill = ifelse(`is_1`, groep, NA)), data = table_v, size = rel(1.5)) + ggtitle("Distribution of the 8 samples") + labs(caption = paste("K = ", nanchestors, "")) + guides(fill = guide_legend(title = "Ancestor\npopulation")) + theme(axis.ticks = element_blank(), axis.text = element_blank(), axis.title = element_blank())
	ggsave(sub("\\.(mean)?Q$", "-kaart.png", Q.file))
}
