#!/usr/bin/env Rscript
# changing invaders
# by david
# barplot voorouder output
if (length(commandArgs(trailingOnly=TRUE))==0) {
	Q.bestanden <- file.info(paste0(list.files(pattern = "\\.(mean)?Q$")))
	Q.bestanden <- rownames(Q.bestand[with(Q.bestand, order(mtime, decreasing = TRUE)), ][1,])
} else {
	Q.bestanden <- commandArgs(trailingOnly=TRUE)[1]
}
for (Q.bestand in Q.bestanden) {
	tbl <- read.table(Q.bestand)
	rownames(tbl) <- sub("_.*", "", read.table("merge8.fam")$V2)
	tbl
	nvoorouders <- as.numeric(rev(strsplit(Q.bestand, "\\.")[[1]])[2])
	png(paste0(ifelse(grep("-struct", Q.bestand), "faststructure", "admixture"), "_", sub("-struct", "", sub("\\.(mean)?Q$", "", Q.bestand)), ".png"))
		barplot(t(as.matrix(tbl)), col=rainbow(nvoorouders), ylab="Ancestry", border=NA, las=2)
		title(sub("([0-9]+)", "(aanname: \\1 voorouders)", sub("(admixt|struct)", "\\1ure", gsub("\\.|-", " ", sub("\\.(mean)?Q$", "", Q.bestand)))))
		# legend(2, 0.5, legend = c("Overig", "Filipijnen", "Nieuw Zeeland", "Thailand"), lty=c(1, 1), col = rainbow(nvoorouders))
	dev.off()
}
