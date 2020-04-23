#!/bin/bash
# changing invaders
# script to get mutations back from genes of a GO group
group="Anatomical structure morphogenesis"
[ $# -gt 0 ]&&group="$1"
# get the line with the required ontological group,
# get from that only the genes (5th column)
# put every geneon a single line, and put before and after every gene a \|
# which makes it the regex |gen-naam|
# place on the first line (before the first gene)
# a line that in regex means as first character #, second character all but #
# (header line with samples will be added this way)
# next this all (genes and header line) will be searched in merge8.ann.vcf
# (the vcf file). Get then the bases, and the sample specific information (for the genotypes)
# (and throw away the rest).
# Keep from the sample specific information only the genotypes (first field seperated on :)
# format all bases to a list seperated on ,'s
# remove the first filed in the sample name header (does not contain name) and display
# from the 2nd character (so one starts with the 2nd field)
# replace the genotypes to bases, and remove by this the first bases column
# replace in the first column the samplenames by the short variant (only the part to the _)
grep "$group" GO_BIOLOGICAL_PROCESS_enrichment_ALL.csv|cut -d, -f5|xargs echo|tr ' ' $'\n'|sed -E 's/^|$/\\|/g'|sed '1s/^/^#[^#]\n/'|egrep -f- merge8.ann.vcf |cut -d$'\t' -f4,5,10-|sed -e 's/:[^\t]*//g' -e 's/\t/,/'|awk '{if (NR==1){$1="";print substr($0, 2)}else{a=$1;split(a,b,",");for(i=2;i<=NF;i++) { split($i, c, "/");printf b[c[1]+1]"/"b[c[2]+1]"\t" }print ""}}'|sed '1s/_[^\t ]*./\t/g'
