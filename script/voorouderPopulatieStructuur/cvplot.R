#!/usr/bin/env Rscript
library(ggplot2)
# cd logs
# grep -h CV admixture-pruned-*.out |cut -d= -f2|sed '1s/^/K,cross.validated\n/;s/): /,/' >../admixture.cross.validated
# grep -h CV admixture-bootstrap-pruned-*.out |cut -d= -f2|sed '1s/^/K,cross.validated\n/;s/): /,/' >../admixture-bootstrap.cross.validated
# grep -h CV admixture-merge0.3k*.out |cut -d= -f2|sed '1s/^/K,cross.validated\n/;s/): /,/' >../admixture0.3k.cross.validated
# grep -h CV admixture-merge0.1k*.out |cut -d= -f2|sed '1s/^/K,cross.validated\n/;s/): /,/' >../admixture0.1k.cross.validated
# grep -h CV admixture-mergemax*.out |cut -d= -f2|sed '1s/^/K,cross.validated\n/;s/): /,/' >../admixturemax.cross.validated
# grep 'Marginal Likelihood' merge0.3k*|sed -e 's/.log.* /,/' -e 's/.*struct\.//' -e '1s/^/K,Marginal Likelihood\n/' > ../structure-0.3k.ml
# grep 'Marginal Likelihood' merge0.1k*|sed -e 's/.log.* /,/' -e 's/.*struct\.//' -e '1s/^/K,Marginal Likelihood\n/' > ../structure-0.1k.ml
# cd ..
ggplot(read.csv("admixture.cross.validated")) + geom_line(aes(K, cross.validated)) + ggtitle("Waardes van aantal voorouders", subtitle = "tegenover de cross-validation error estimate")
ggsave("admixture.cross.validated.png")
ggplot(read.csv("admixture-bootstrap.cross.validated")) + geom_line(aes(K, cross.validated)) + ggtitle("Waardes van aantal voorouders", subtitle = "tegenover de cross-validation error estimate")
ggsave("admixture-bootstrap.cross.validated.png")
ggplot(read.csv("admixture0.3k.cross.validated")) + geom_line(aes(K, cross.validated)) + ggtitle("Waardes van aantal voorouders", subtitle = "tegenover de cross-validation error estimate")
ggsave("admixture0.3k.cross.validated.png")
ggplot(read.csv("admixture0.1k.cross.validated")) + geom_line(aes(K, cross.validated)) + ggtitle("Waardes van aantal voorouders", subtitle = "tegenover de cross-validation error estimate")
ggsave("admixture0.1k.cross.validated.png")
ggplot(read.csv("admixturemax.cross.validated")) + geom_line(aes(K, cross.validated)) + ggtitle("Waardes van aantal voorouders", subtitle = "tegenover de cross-validation error estimate")
ggsave("admixturemax.cross.validated.png")
ggplot(read.csv("structure-0.3k.ml")) + geom_line(aes(K, Marginal.Likelihood)) + ggtitle("Waardes van aantal voorouders", subtitle = "tegenover de Marginal Likelihood estimate")
ggsave("structure-0.3k.ml.png")
ggplot(read.csv("structure-0.1k.ml")) + geom_line(aes(K, Marginal.Likelihood)) + ggtitle("Waardes van aantal voorouders", subtitle = "tegenover de Marginal Likelihood estimate")
ggsave("structure-0.1k.ml.png")
