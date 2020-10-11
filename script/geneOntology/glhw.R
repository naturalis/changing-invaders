# glhw
# changing invaders
# by david
# script to convert genotypes to numbers
# half disjunctive table
# (complete disjunctive in many cases)
# (sometimes reducing of 1 variable)
# (in cases with (all linking bases) in between gentypes representing as one variable)
# setwd(Sys.glob("~/Doc*/Nat*/gen*ont*"))
if (length(commandArgs(trailingOnly=T))>0) process <- commandArgs(trailingOnly=T) else {
	gt_files <- list.files(pattern = "*\\.gt$")
	# give if possible a graphical menu with all .gt files, where the user can choose one or more for the MCA
	processes <- select.list(gt_files, multiple = TRUE, title = "Choose a genotype file")
	if (length(processes)==0) processes = gt_files
}
1
process = processes[1]
for (process in processes) {
	process
	class.ind <- function(cl) {
	    n <- length(cl)
	    cl <- as.factor(cl)
	    complete.disjunctive.table <- matrix(FALSE, n, length(levels(cl)))
	    complete.disjunctive.table[(1L:n) + n * (unclass(cl) - 1)] <- TRUE
	    dimnames(complete.disjunctive.table) <- list(names(cl), levels(cl))
	    complete.disjunctive.table
	}

	ASM <- read.table(process, TRUE, stringsAsFactors = TRUE)
	nextval <- 1
	givmenext <- function() {
		nextval <<- nextval + 1
		x <<- t(ASM)[,nextval]
		print(x)
	}
	# givmenext()
	resulting <- c()
	# names(resulting) <- names(ASM)
	invisible(apply(ASM, 1, function(x) {
		firstRow <- mapply(`[`, strsplit(x, "/"), 1)
		secondRow <- mapply(`[`, strsplit(x, "/"), 2)
		the.matrix <- class.ind(firstRow)
		the.next.matrix <- class.ind(secondRow)
		z <<- x
		if (all(is.na(secondRow))) {
			return.rows = as.data.frame(t(the.matrix))
		} else {
			secondRow[is.na(secondRow)] <- firstRow[is.na(secondRow)]
			if (is.logical(all.equal(the.next.matrix, the.matrix))) {
				if (ncol(the.next.matrix)<3) {
					return.rows <- the.next.matrix[,1]
					# defaults false rows to zero
					return.rows[return.rows] <- 1
					return.rows <- as.data.frame(t(return.rows))
				} else {
					the.next.matrix[the.next.matrix] <- 1
					the.next.matrix <- t(the.next.matrix)
					rownames(the.next.matrix) <- NULL
					return.rows <- as.data.frame(the.next.matrix)
				}
				# check of dit kan simplificeren
				# anders als volledige rijen
			} else {
				# creation of the other matrix (that explain the shared bases in the genotypes we have)
				{
					names.of.the.matrix <- unique(c(firstRow, secondRow))
					the.other.matrix <- matrix(FALSE, length(names.of.the.matrix), length(names.of.the.matrix))
					dimnames(the.other.matrix) <- list(names.of.the.matrix, names.of.the.matrix)
					full_data <- data.frame(first = firstRow, second = secondRow)
					invisible(apply(full_data, 1, function(y) {
						the.other.matrix[y['second'],y['first']] <<- TRUE
						the.other.matrix[y['first'],y['second']] <<- TRUE
					}))
					diag(the.other.matrix) <- FALSE
				}
				# if any base has more than two (with the exception of self) connections, it is clear that is matrix is not meant to simplify
				# it is simply too complex to do it (basically positive discrimiation)
				# if every value is 2 no value will be 1 so is.na on table(1) will be true
				# if that is the case any base is connected to two others so a loop exist that is not simply simplifiable
				# if any value is 0 there is no connection between 1 base and it is not simplifiable
				if ((any(colSums(the.other.matrix) == 0))||(any(rowSums(the.other.matrix) == 0))
					|| any(colSums(the.other.matrix) > 2)||any(rowSums(the.other.matrix) > 2)||
					is.na(table(colSums(the.other.matrix))[1])||is.na(table(rowSums(the.other.matrix))[1])) {
					# apply the complex dataset to the data we have
					the.other.matrix <- cbind(the.matrix, the.next.matrix)
					the.other.matrix[the.other.matrix] <- 1
					return.rows <- as.data.frame(t(the.other.matrix))
					rownames(return.rows) <- NULL
				} else {
					# try to simplify the data we have
					# do this by checking the very first 1 value for a row or column, then getting that base, and removing from the matrix
					# adding that base to nucleotidebaselist
					# until the matrix is no longer a matrix
					continue <- TRUE
					nucleotidebase <- names(rowSums(the.other.matrix)[1])
					nucleotidebaselist <- c(nucleotidebase)
					while (continue) {
						#print(paste0("extracting:", nucleotidebase))
						selection <- the.other.matrix[nucleotidebase,]
						nucleotidebaselist <- c(nucleotidebaselist, names(selection[selection])[1])
						#print(nucleotidebaselist)
						the.other.matrix <- the.other.matrix[rownames(the.other.matrix)!=nucleotidebase,colnames(the.other.matrix)!=nucleotidebase]
						nucleotidebase <- rev(nucleotidebaselist)[1]
						#print(nucleotidebase)
						if (inherits(the.other.matrix, "logical")) continue <- FALSE
					}
					# defining the first as 0, now creating a genotypelist where every increasing genotype is +0.5 until all are defined
					nucleotidebase <- ""
					genotypelist <- c()
					number <- 0
					sapply(nucleotidebaselist, function(y) {
						if (nucleotidebase=="") {
							genotypelist <<- c(genotypelist, paste0(y, "/", y), y)
							names(genotypelist) <<- c(Filter(nchar, names(genotypelist)), number, number)
							number <<- number + 0.5
						} else {
							genotypelist <<- c(genotypelist, paste0(nucleotidebase, "/", y), paste0(y, "/", nucleotidebase), paste0(y, "/", y), y)
							names(genotypelist) <<- c(Filter(nchar, names(genotypelist)), number, number, number + 0.5, number + 0.5)
							number <<- number + 1
						}
						nucleotidebase <<- y
					})
					# creating two dataframes, merging both on genotypes, and finally only obtaining the samples/values as vector
					return.rows <- merge(data.frame(x = x, sample = names(x)), data.frame(value = names(genotypelist), base = genotypelist), by.x = "x", by.y = "base")
					rownames(return.rows) <- return.rows$sample
					return.rows[,c("sample", "x")] <- NULL
					return.actual.rows <- return.rows$value
					names(return.actual.rows) <- rownames(return.rows)
					return.rows <- as.numeric(return.actual.rows)
					names(return.rows) <- names(return.actual.rows)
				}
			}
		}
		print(x)
		print(return.rows)
		tryCatch(resulting <<- rbind(resulting, return.rows), warning = function(e) {print(return.rows);print(x)}, error = function(e) {print(return.rows);print(x)})
		if (ncol(resulting)==1) {print(x);break}
		NULL
	}))
	rownames(resulting) <- NULL
	resulting
	write.table(resulting, file = sub("\\.gt$", ".bgt", process), sep = "\t", quote = FALSE, row.names = FALSE)
}

# write.table(read.table("coding.bgt", header = TRUE), "coding.bgt", sep = "\t", quote = FALSE, row.names = FALSE)
