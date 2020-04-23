#!/bin/bash
# changing invaders
# script to extract mutations from genes of a GO group
# but only HIGH impact
# and where nieuw zeeland samples are different then the others (and equal towards each other)
# + annotation
group="Anatomical structure morphogenesis"
[ $# -gt 0 ]&&group="$1"
# echo $group
# search group in the go enrichment
# get from this only the genes, that you put all on its own line and add as first line ^#[^#]
# (first character # second character all but #).
# This so there can be searched on all genes in the vcf file,
# and the header line with the samplenames stays above.
# now only get REF, ALT (bases), all sample specific information (genotype etc.) and INFO
# remove all sample specific data except for the first property (genotype)
# replace the first tab by a comma, so the first field becomes a list (seperated by ,)
# that contains all occuring bases
# put INFO field as last
# before the first line: remove the first two fields
# for the rest: calculate the genotype in bases instead of numbers
# replace the samplename in the header by only the first part
# check whether the NZ samples have equal genotypes and divergent from the other samples
# if yes, show them
# search only HIGH impact mutations
# get only the genotypes (remove the INFO field)
grep "$group" GO_BIOLOGICAL_PROCESS_enrichment_ALL.csv|cut -d, -f5|tr ' ' $'\n'|sed '1s/^/^#[^#]\n/'|egrep -f- merge8.ann.vcf|cut -d$'\t' -f4,5,10-,8|sed -e 's/:[^\t]*//g' -e 's/\t/,/'|sed -E 's/\t([^\t]*)(.*)/\2\t\1/'|awk '{if (NR==1){$1="";print substr($0, 2)}else{a=$1;split(a,b,",");for(i=2;i<=NF-1;i++) { split($i, c, "/");printf b[c[1]+1]"/"b[c[2]+1]"\t" }print $NF}}'|sed '1s/_[^\t ]*./\t/g'|awk '$4==$6&&$4!=$1&&$4!=$2&&$4!=$3&&$4!=$5&&$4!=$7&&$4!=$8{print}{if(NR==1)print}'|grep -P '[^|]+(?=\|HIGH|INFO)'|cut -d$'\t' -f1-8
