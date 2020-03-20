#!/bin/bash
# changing invaders
# een script om de genotypes van alle coderende (CNS)SNPs op te slaan in coding.gt
# dit is mogelijk nuttig voor een MCA
#
# neem van het geannoteerde bestand met enkel CNSSNPs, de basen en de sample genotypes (andere sample informatie word
# later verwijderd) maak van de basen een komma gescheiden lijst. verwijder de header regels (behalve de sample header)
# laat de header vanaf het tweede veld zien (het eerste veld is geen samplenaam maar REF,ALT) en geef de genotypes weer
# in basen waarbij homozygote genotypes (A/A) worden verkleint tot een enkele base (A)
# vervang nu van de samplenamen het laatste gedeelte zodat enkel het korte, eerste gedeelte overblijft
# en sla dat op in coding.gt
cut -d$'\t' -f4,5,10- merge8.ann.vcf|sed -e 's/:[^\t]*//g' -e 's/\t/,/'|egrep -v '^#'|awk '{if (NR==1){$1="";print substr($0, 2)}else{a=$1;split(a,b,",");for(i=2;i<=NF;i++) { split($i, c, "/");if (b[c[1]+1]==b[c[2]+1])printf b[c[2]+1]"\t"; else printf b[c[1]+1]"/"b[c[2]+1]"\t" }print ""}}'|sed '1s/_[^\t ]*./\t/g' > coding.gt
