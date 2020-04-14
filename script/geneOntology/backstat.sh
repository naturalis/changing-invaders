#!/bin/bash
# changing invaders
# script om mutaties terug te halen vanuit genen van een GO groep
groep="Anatomical structure morphogenesis"
[ $# -gt 0 ]&&groep="$1"
# pak de regel met de gewenste ontologische groep,
# neem daarvan enkel de genen (5e kolom)
# zet ieder gen op een losse regel, en zet voor en na ieder gen \|
# waardoor dit als regex |gen-naam| vindt
# plaats op de eerste regel (voor het eerste gen)
# een regel die in regex aangeeft een regel dat begint met een # gevolgd
# door een niet # (header regel met samples wordt zo meegenomen)
# vervolgens wordt dit alles (de genen en die header regel) gezocht in merge8.ann.vcf
# (het vcf bestand). Neem vervolgens de basen, en de sample specifieke informatie (voor de genotypes)
# (en gooi de rest weg).
# Behoud van de sample specifieke data enkel de genotypes (eerste veld gescheiden op :)
# maak van alle basen een lijst gescheiden op ,'s
# verwijder eeste veld in de sample naam header (bevat geen sample namen) en weergeef
# vanaf het 2e teken (zodat men bij het 2e veld begint)
# zet de genotypes om in basen, en verwijder hiermee de eerste basen kolom
# vervang in de eerste kolom de samplenamen door de korte variant (enkel het deel tot de _)
grep "$groep" GO_BIOLOGICAL_PROCESS_enrichment_ALL.csv|cut -d, -f5|xargs echo|tr ' ' $'\n'|sed -E 's/^|$/\\|/g'|sed '1s/^/^#[^#]\n/'|egrep -f- merge8.ann.vcf |cut -d$'\t' -f4,5,10-|sed -e 's/:[^\t]*//g' -e 's/\t/,/'|awk '{if (NR==1){$1="";print substr($0, 2)}else{a=$1;split(a,b,",");for(i=2;i<=NF;i++) { split($i, c, "/");printf b[c[1]+1]"/"b[c[2]+1]"\t" }print ""}}'|sed '1s/_[^\t ]*./\t/g'
