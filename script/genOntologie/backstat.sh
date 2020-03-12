#!/bin/bash
# script om mutaties terug te halen vanuit genen
groep="Anatomical structure morphogenesis"
[ $# -gt 0 ]&&groep="$1"
grep "$groep" GO_BIOLOGICAL_PROCESS_enrichment_ALL.csv|cut -d, -f5|tr ' ' $'\n'|sed '1s/^/^#[^#]\n/'|egrep -f- merge8.ann.vcf --color=yes|cut -d$'\t' -f4,5,10-|sed -e 's/:[^\t]*//g' -e 's/\t/,/'|awk '{if (NR==1){$1="";print substr($0, 2)}else{a=$1;split(a,b,",");for(i=2;i<=NF;i++) { split($i, c, "/");printf b[c[1]+1]"/"b[c[2]+1]"\t" }print ""}}'\
|sed '1s/_[^\t ]*./\t/g'

# cut -d$'\t' -f4,5,10- merge8.ann.vcf|sed -e 's/:[^\t]*//g' -e 's/\t/,/'|egrep -v '^#'|awk '{if (NR==1){$1="";print substr($0, 2)}else{a=$1;split(a,b,",");for(i=2;i<=NF;i++) { split($i, c, "/");if (b[c[1]+1]==b[c[2]+1])printf b[c[2]+1]"\t"; else printf b[c[1]+1]"/"b[c[2]+1]"\t" }print ""}}'|sed '1s/_[^\t ]*./\t/g' > coding.gt
