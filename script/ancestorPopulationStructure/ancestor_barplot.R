#!/usr/bin/env Rscript
# changing invaders
# by david
# barplot anchestor output
# If no file is given, all K values of the last saved Q file is plotted
if (length(commandArgs(trailingOnly=TRUE))==0) {
	Q.files <- file.info(paste0(list.files(pattern = "\\.(mean)?Q$")))
	Q.files <- rownames(Q.files[with(Q.files, order(mtime, decreasing = TRUE)), ][1,])
} else {
	Q.files <- commandArgs(trailingOnly=TRUE)
}
for (Q.file in Q.files) {
	tbl <- read.table(Q.file)
	rownames(tbl) <- sub("_.*", "", read.table("merge8.fam")$V2)
	tbl
	n_anchestors <- as.numeric(rev(strsplit(Q.file, "\\.")[[1]])[2])
	png(paste0(ifelse(grep("-struct", Q.file), "faststructure", "admixture"), "_", sub("-struct", "", sub("\\.(mean)?Q$", "", Q.file)), ".png"))
		barplot(t(as.matrix(tbl)), col=rainbow(n_anchestors), ylab="Ancestry", border=NA, las=2)
		title(sub("([0-9]+)", "(assumption: \\1 anchestors)", sub("(admixt|struct)", "\\1ure", gsub("\\.|-", " ", sub("\\.(mean)?Q$", "", Q.file)))))
		# legend(2, 0.5, legend = c("Other", "Philippines", "New Zealand", "Thailand"), lty=c(1, 1), col = rainbow(n_anchestors))
	dev.off()
}
