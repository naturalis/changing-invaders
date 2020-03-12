#!/bin/bash
# script om mutaties terug te halen vanuit genen
select="$(eval echo $(eval kdialog --geometry 700x500  --checklist \"Kies een gen groep uit de lijst:\" $(cut -d, -f1,4 GO_BIOLOGICAL_PROCESS_enrichment_ALL.csv|sed p|sed -E 's/^|$/"/g'|tr \\n ' ')))"
[ "$select" = "" ]&& { echo Gebruiker sluit af;exit;}
groep=$(echo "$select"|cut -d, -f2)
#groep="Anatomical structure morphogenesis"
qdbus org.kde.yakuake /yakuake/window toggleWindowState
grep "$groep" GO_BIOLOGICAL_PROCESS_enrichment_ALL.csv|cut -d, -f5|tr ' ' $'\n'|sed '1s/^/^#[^#]\n/'|egrep -f- merge8.ann.vcf --color=yes|cut -d$'\t' -f4,5,10-|sed -e 's/:[^\t]*//g' -e 's/\t/,/'|awk '{if (NR==1){$1="";print substr($0, 2)}else{a=$1;split(a,b,",");for(i=2;i<=NF;i++) { split($i, c, "/");printf b[c[1]+1]"/"b[c[2]+1]"\t" }print ""}}'|sed -E \
-e $'1!s/A/\033[1;31m&\033[0m/g' \
-e $'1!s/C/\033[1;32m&\033[0m/g' \
-e $'1!s/G/\033[1;33m&\033[0m/g' \
-e $'1!s/T/\033[1;34m&\033[0m/g' \
|sed '1s/_[^\t ]*./\t/g'|less
