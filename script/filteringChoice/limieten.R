#!/usr/bin/env Rscript
# changing invaders
# by david
# script to obtain user-defined limits
library(ggplot2)
library(grid)
setwd("~/Documenten/Naturalis/")
q <- read.csv("quality log10", row.names = 1)
p <- read.csv("quality.csv", row.names = 1)
coverage <- read.csv("depth1.csv", row.names = 1)

ggplot(cbind(p, q), aes(cov, amount)) + geom_col() + xlab("quality")
ggplot(cbind(p, q), aes(cov, x)) + geom_col() + xlab("quality")
ggplot(cbind(p, q), aes(cov, log(amount))) + geom_col() + xlab("quality")

ggplot(coverage, aes(cov, log2(amount))) + geom_col() + xlab("quality")
ggplot(coverage, aes(cov, amount)) + geom_col() + xlab("quality")

amount <- coverage$amount
names(amount) <- coverage$cov
barplot(amount)

limits <- c()
for (x in 1:2) {
	value = locator(1)$x
	abline(v = value, col = "red")
	limits <- c(limits, value)
}
limits
