setwd("Documenten/Naturalis/")
q <- read.csv("kwaliteit log10", row.names = 1)
p <- read.csv("kwaliteit.csv", row.names = 1)
coverage <- read.csv("diepte1.csv", row.names = 1)
library(ggplot2)
library(grid)

ggplot(cbind(p, q), aes(cov, hoeveel)) + geom_col() + xlab("kwaliteit")
ggplot(cbind(p, q), aes(cov, x)) + geom_col() + xlab("kwaliteit")
ggplot(cbind(p, q), aes(cov, log(hoeveel))) + geom_col() + xlab("kwaliteit")

ggplot(coverage, aes(cov, log2(hoeveel))) + geom_col() + xlab("kwaliteit")
ggplot(coverage, aes(cov, hoeveel)) + geom_col() + xlab("kwaliteit")

h <- coverage$hoeveel
names(h) <- coverage$cov
barplot(h)

limieten <- c()
for (x in 1:2) {
	value = locator(1)$x
	abline(v = value, col = "red")
	limieten <- c(limieten, value)
}
limieten
