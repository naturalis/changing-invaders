stop = FALSE
f = stdin()
print(readLines("stdin", n = 2))
print(readLines(f, n = 1))
print(readLines("stdin", n = 1))
# tabel met nummers en samplenamen
# de nummers staan in de database ipv sample namen
lookup <- read.table("/data/david.noteborn/sample-enum.csv", header = FALSE, col.names = c("sample", "num"), sep = ",")
# voor ieder bestand: maak een header aan
vcfheader <- paste0(readLines(paste0(Sys.getenv("HOME"), "/vcfheader"), 53), collapse="\n")
for (sample in lookup$sample) write(sub("SAMPLES", sample, vcfheader), paste0(sample, ".filter.vcf"))
while(!stop) {
	next_line = readLines(f, n = 1)
	print(next_line)
	if(length(next_line) == 0) {
		stop = TRUE
		close(f)
	} else {
		print(next_line)
		if (next_line!="") {
			a <- unlist(strsplit(next_line, "\t"))
			print(length(a))
			if (!is.na(a[11])) TRUE
				write(paste0(paste0(c(a[1:2], ".", a[3:5], ".", paste0("DP=", a[6]), "GT:PL", paste(a[7:8], collapse = ":")), collapse = "\t"), "\n"), paste0(lookup[lookup$num==a[11],"sample"], ".filter.vcf"), append = TRUE)
		}
	}
}
