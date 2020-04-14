#!/usr/bin/env Rscript
# changing invaders
# by david
# barplot anchestor output
library(ggmap, quietly = TRUE)
library(ggrepel)
library(dplyr, warn.conflicts = FALSE)
library(scatterpie)
if (length(commandArgs(trailingOnly = TRUE)) == 0) {
	Q.bestanden <- file.info(paste0(list.files(pattern = "\\.(mean)?Q$")))
	Q.bestanden <- rownames(Q.bestanden[with(Q.bestanden, order(mtime, decreasing = TRUE)), ][1,])
	Q.bestanden <- rownames(file.info(paste0(list.files(pattern = sub("(.[^.]+){2}$", "\\.[0-9]+.*Q$", Q.bestanden)))))
} else Q.bestanden <- commandArgs(trailingOnly = TRUE)

lijst <- "GMI-4 -> Great Mercuri Island, New Zealand North Island, lt -36.6155, long. 175.7938
L0234 -> Laos, Champasak province, lt 15.20989, long. 105.7906
C0910 -> Cambodia, Pursat province lat. 12.57472, long. 104.2075
L0235 -> Laos, Champasak province, lat. 15.20989, long. 105.7906
P0041 -> Philippines, Tarlac, lat. 15.43469, long. 120.4959
R6750 -> Thailand, Prachuap-Khiri-Khan province, lat. 11.78622 long. 99.648933
R7129 -> Thailand, Tak province, lat. 16.80463, long. 98.73463
R14018-> Doubtful Sound, New Zealand South Island, lat. -45.3502, long. 167.0018"
tabel <- as.data.frame(Reduce(rbind, strsplit(unlist(strsplit(lijst, "\n")), " ?-> |,? la?t\\.? |,? long. ")), stringsAsFactors = FALSE)
colnames(tabel) <- c("SAMPLE", "LOCATIE", "LATITUDE", "LONGDITUDE")
rownames(tabel) <- tabel$SAMPLE
tabel$LATITUDE <- as.numeric(tabel$LATITUDE)
tabel$LONGDITUDE <- as.numeric(tabel$LONGDITUDE)
if (file.exists("~/structuur/kaart.rdata")) load("~/structuur/kaart.rdata") else {
	kaart <- get_stamenmap(c(min(tabel$LONGDITUDE) - 1, min(tabel$LATITUDE) - 1, max(tabel$LONGDITUDE) + 1, max(tabel$LATITUDE) + 1), 5)
	save(kaart, file = "~/structuur/kaart.rdata")
}
for (Q.bestand in Q.bestanden) {
	tbl_orig <- read.table(Q.bestand)
	tbl <- round(tbl_orig, digits = 2)
	rownames(tbl) <- sub("_.*", "", read.table("~/structuur/merge8.fam")$V2)
	colnames(tbl) <- as.character(1:ncol(tbl))
	# the sample name in the plot is the sort (up to the _) version within the fam file
	tbl$SAMPLE <- sub("_.*", "", read.table("~/structuur/merge8.fam")$V2)
	sub("(([1-9]+)[0-9]?\\b)", "(aanname: \\1 voorouders)", sub("(admixt|struct)", "\\1ure", gsub("\\.|-", " ", sub("\\.(mean)?Q$", "", Q.bestand))))
	nvoorouders <- as.numeric(rev(strsplit(Q.bestand, "\\.")[[1]])[2])

	# create a long table with the groups
	beter_tabel <- full_join(tabel, tidyr::pivot_longer(tbl, c(as.character(1:(ncol(tbl) - 1))), "groep", values_to = "kans"), "SAMPLE")
	# store the most apparent group
	tabel_v <- full_join(tabel, beter_tabel %>% group_by(SAMPLE) %>% summarise(groep = groep[kans == max(kans)]), "SAMPLE")
	# if the long table explains that a group makes up about 0.999 part of an organism
	# make is_1 true, so we wont put there a cirkeldiagram
	tabel_v <- full_join(beter_tabel %>% mutate(rond = round(kans, 2)) %>% mutate(is_1 = (rond == 0 | rond == 1)) %>% group_by(SAMPLE) %>% summarise(is_1 = all(is_1)), tabel_v, "SAMPLE")
	# give tbl more properties
	tbl <- full_join(tabel_v %>% select(LATITUDE, LONGDITUDE, SAMPLE, is_1), tbl, "SAMPLE")
	# get the map
	ggmap(kaart) + geom_point(aes(LONGDITUDE, LATITUDE), data = tabel_v) + geom_scatterpie(aes(LONGDITUDE, ifelse(!is_1, LATITUDE, NA)), tbl, na.rm = TRUE, cols = as.character(1:(ncol(tbl) - 4))) + geom_label_repel(aes(LONGDITUDE, LATITUDE, label = SAMPLE, fill = ifelse(`is_1`, groep, NA)), data = tabel_v, size = rel(1.5)) + ggtitle("Distribution of the 8 samples") + labs(caption = paste("K = ", nvoorouders, "")) + guides(fill = guide_legend(title = "Ancestor\npopulation")) + theme(axis.ticks = element_blank(), axis.text = element_blank(), axis.title = element_blank())
	ggsave(sub("\\.(mean)?Q$", "-kaart.png", Q.bestand))
}
