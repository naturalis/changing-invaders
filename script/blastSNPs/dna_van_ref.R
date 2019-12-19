# dna van ref
# changing invaders
# by david
# biostrings is nodig (BiocManager::install("Biostrings"))
library("Biostrings")
# lees het fasta basetand in.
# dit duurt wel even
s = readDNAStringSet("REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa")
# bewerk de namen zodat het enkel het chromosoom nummer is
names(s) <- mapply(`[`, strsplit(names(s), " "), 1)
posities <- read.csv("/data/david.noteborn/filtered_snps.csv", row.names = 1)
posities <- posities[posities$chromosome!=0,]
sequences <- apply(posities, 1, function(x) toString(subseq(s[[x["chromosome"]]], start=as.numeric(x["position"])-250, end=as.numeric(x["position"])+250)))
# voeg sequenties toe aan positie tabel
posities$voor <- substr(sequences, 1, 250)
posities$na <- substr(sequences, 252, 501)
posities$ref <- substr(sequences, 251, 251)
write.csv(posities, "filtered_snps_seq.csv", row.names = FALSE)
# sed -nE '1!{s/([0-9]+,[0-9]+),"([^"]+)","([^"]+)","(.)"/>\1-\4\n\2\n>\1-\4\n\3/p}' filtered_snps_seq.csv > filtered_snps_seq.fasta