#!/bin/bash
# script om mutaties terug te halen vanuit genen
# + annotatie
groep="Anatomical structure morphogenesis"
[ $# -gt 0 ]&&groep="$1"
echo $groep
grep "$groep" GO_BIOLOGICAL_PROCESS_enrichment_ALL.csv|cut -d, -f5|tr ' ' $'\n'|sed '1s/^/^#[^#]\n/'|egrep -f- merge8.ann.vcf --color=yes|cut -d$'\t' -f4,5,10-,8|sed -e 's/:[^\t]*//g' -e 's/\t/,/'|sed -E 's/\t([^\t]*)(.*)/\2\t\1/'|awk '{if (NR==1){$1="";print substr($0, 2)}else{a=$1;split(a,b,",");for(i=2;i<=NF-1;i++) { split($i, c, "/");printf b[c[1]+1]"/"b[c[2]+1]"\t" }print $NF}}'
grep "$groep" GO_BIOLOGICAL_PROCESS_enrichment_ALL.csv|cut -d, -f5|tr ' ' $'\n'|sed '1s/^/^#[^#]\n/'|egrep -f- merge8.ann.vcf --color=yes|cut -d$'\t' -f4,5,10-,8|sed -e 's/:[^\t]*//g' -e 's/\t/,/'|sed -E 's/\t([^\t]*)(.*)/\2\t\1/'|awk '{if (NR==1){$1="";print substr($0, 2)}else{a=$1;split(a,b,",");for(i=2;i<=NF-1;i++) { split($i, c, "/");printf b[c[1]+1]"/"b[c[2]+1]"\t" }print $NF}}'|sed '1s/_[^\t ]*./\t/g'|awk '$4==$6&&$4!=$1&&$4!=$2&&$4!=$3&&$4!=$5&&$4!=$7&&$4!=$8{print}'|grep -P '[^|]+(?=\|HIGH)'|cut -d$'\t' -f1-8
