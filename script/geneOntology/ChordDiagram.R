# circosPlot
# changing invaders
# by david
# script to plot aminoacid changes
# find non header lines
# find and keep only (aa transitions (so eg p.Aug2Gln))Upper lower lower(char)one or more numbers Upper lower lower
#  remove the first p. (first 2 characters)
#  replace the number to a ,
# sort the result, and count the occurences
# sort the result on numberic
# replace starting spaces and replace intermediate spaces to ,
# grep -v ^\# merge8.ann.vcf|grep -Po 'p\.[A-Z][a-z]{2}[0-9]+[A-Z][a-z]{2}'|sed -e 's/p.//' -Ee 's/[0-9]+/,/'|sort|uniq -c|sort -n|sed -Ee 's/^ +//' -e 's/ /,/' > merge8.aminoacid.mutation.table
# declare -i num=1;for sample in L0235_41658 L0234_41660 C0910_41662 GMI-4_41656 P0041_41663 R14018_41657 R6750_41661 R7129_41659.sort.bam;do grep -v ^\# merge8.ann.vcf |grep -vP '0/0[^\t]+(\t[^\t]+){'$((8-$(echo num)))'}$'|sed -Ee 's/GT:PL([^\t]*\t){'$num'}([^:]+).*/\2/' -e 's/^.*ANN=//'|awk -F$'\t' '{split($2, a, "/");split($1, b, ",");if (a[1]!=0){print(b[a[1]]);}if (a[2]!=0){print(b[a[2]]);}}'|grep -Po 'p\.[A-Z][a-z]{2}[0-9]+[A-Z][a-z]{2}'|sed -e 's/p.//' -Ee 's/[0-9]+/,/'|sort|uniq -c|sort -n|sed -Ee 's/^ +//' -e 's/ /,/' > $sample.aminoacid.mutation.table;num+=1;done
library(tidyr)
library(circlize)
setwd(Sys.glob("~/D*/Nat*/gen*-ontol*/"))
# creation of static variables
{
  aa <- unlist(strsplit("Arg|His|Lys|Asp|Glu|Ser|Thr|Asn|Gln|Cys|Sec|Gly|Pro|Ala|Val|Ile|Leu|Met|Phe|Tyr|Trp", "|", fixed = TRUE))
  mapping <- c("Terminatie Codons", rep("Positief geladen zijketens", 3), rep("Negatief geladen zijketens", 2), rep("Polair ongeladen zijketens", 4), rep("Speciale gevallen", 3), rep("Hydrofobe zijketens", 8))
  mapping <- c("Termination Codons", rep("Positive charged sidechains", 3), rep("Negative charged sidechains", 2), rep("Polar uncharged sidechains", 4), rep("Special cases", 3), rep("Hydrophobe sidechains", 8))
  mapping <- c(paste("from", mapping), paste("to", mapping))
  names(mapping) <- c("Ter", grep(value = TRUE, invert = TRUE, "Sec", aa))
  names_for_mapping <- c("Ter", grep(value = TRUE, invert = TRUE, "Sec", aa))
  names(mapping) <- c(paste("from", names_for_mapping), paste("to", names_for_mapping))
  from_to <- mapping
  from_to[grep("from", mapping)] <- "from"
  from_to[grep("to", mapping)] <- "to"
}
# creation of tables
aa_tables <- Map(Sys.glob("*.aminoacid.mutation.table"), f = function(input) {
  aa_table <- as.data.frame(pivot_wider(rbind(read.table(input, sep = ",", col.names = c("hoeveel", "from", "to")), data.frame(hoeveel = 0, from = "Sec", to = "Sec")), values_from = hoeveel, names_from = from, values_fill = list(hoeveel = 0)))
  rownames(aa_table) <- aa_table$to
  aa_table$to <- NULL
  aa_table <- aa_table[colnames(aa_table),]
  colnames(aa_table) <- paste("from", colnames(aa_table))
  rownames(aa_table) <- paste("to", rownames(aa_table))
  aa_table
})
names(aa_tables) <- sub(".aminoacid.mutation.table$", "", names(aa_tables))
#' Half
#'
#' gives you haf of the elements
#' @param value the value on one wants the half of the elements from
half <- function(value) value[1:(length(value)/2)]
#' circos
#'
#' Make circos plot
#' @param chord_table table that contains data for the Chord diagram
#' @details this builds and plots a Chord diagram. The data is split in 'from' (columns) and 'to' (rows), which are split with a dotted line
#' the colors on both sides are the same per category
circos <- function(chord_table) {
  colors_from_aa <- rep(1:(length(aa)+1), times = 2)
  names(colors_from_aa) <- c(paste("from", c("Ter", aa)), paste("to", c("Ter", aa)))
  circos.par(gap.after = do.call("c", lapply(table(mapping), function(i) c(rep(2, i - 1), 8))), cell.padding = c(0, 0, 0, 0), track.margin = c(0.01, 0.05), track.height = 0.05, start.degree = -95)
  chordDiagram(as.matrix(chord_table), order = names(colors_from_aa), directional = TRUE, transparency = 0.5, annotationTrack = "grid", preAllocateTracks = 2, grid.col = colors_from_aa)

  circos.track(track.index = 1, panel.fun = function(x, y) {
      xlim = get.cell.meta.data("xlim")
      ylim = get.cell.meta.data("ylim")
      sector.index = get.cell.meta.data("sector.index")
      circos.text(mean(xlim), track.index = 3, mean(ylim), sub("(from|to) ", "", sector.index), col = "white", cex = 0.6, facing = "inside", niceFacing = TRUE)
  }, bg.border = NA)


  brand_color = structure(half(2:(1 + length(unique(mapping)))), names = sub("(from|to) ", "", half(unique(mapping))))
  brand_color <- c(brand_color, brand_color)
  names(brand_color) <- c(paste("from", half(names(brand_color))), paste("to", half(names(brand_color))))
  for (b in unique(mapping)) {
    model = names(mapping[mapping == b])
    highlight.sector(sector.index = model, track.index = 1, col = brand_color[b],
      text = gsub(" ", "\n", sub("(from|to) ", "", b)), text.vjust = -0.5, niceFacing = TRUE, padding = c(0,0,0,0))
  }
  brand_color = structure(2:(1 + length(unique(from_to))), names = unique(from_to))
  for (b in unique(from_to)) {
    model = names(from_to[from_to == b])
    highlight.sector(sector.index = model, track.index = 2, col = brand_color[b],
      text = b, niceFacing = TRUE, padding = c(0,0,0,0))
  }
  abline(v = 0, lty = 2, col = "#00000080",lwd = 2)
  circos.clear()
}

for(sample in names(aa_tables)) {
  png(paste0(sample, "_chord.png"))
  par(mar=rep(0, 4), xpd = NA)
  circos(aa_tables[[sample]])
  dev.off()
}
for(sample in names(aa_tables)) circos(aa_tables[[sample]])
