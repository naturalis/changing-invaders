#!/bin/bash
# changing invaders
# script om mutaties terug te halen vanuit genen van een GO groep
# maar enkel HIGH impact
# en waarbij nieuw zeeland samples anders zijn dan de andere (en gelijk aan elkaar)
# + annotatie
groep="Anatomical structure morphogenesis"
[ $# -gt 0 ]&&groep="$1"
# echo $groep
# zoek groep in de go enrichment
# neem daarvan enkel de genen, die je elk op een eigen regel zet en voeg als eerste regel ^#[^#] toe
# (eerste karakter # tweede karakter alles behalve #).
# Dit zodat er gezocht kan worden op alle genen in het vcf bestand,
# en de header regel met de samplenamen erboven blijft staan.
# neem nu enkel REF, ALT (basen) alle sample specifieke informatie (genotype etc.), en INFO
# haal nu sample specifieke data weg behalve de eerste eigenschap (genotype)
# vervang de eerste tab door een komma, zodat als eerste veld een lijst (gescheiden door ,) ontstaat
# die alle basen die voorkomen bevat
# plaats INFO veld als laatste
# voor de eerste regel: verwijder de eerste twee velden
# voor de rest: bereken de genotype in basen ipv getallen
# vervang de sample name in de header door enkel het eerste deel
# controleer of de NZ samples gelijke genotypes hebben en afwijkend van de overige samples
# indien ja, laat zien
# zoek enkel HIGH impact mutaties
# neem enkel de genotypes (verwijder het INFO veld)
grep "$groep" GO_BIOLOGICAL_PROCESS_enrichment_ALL.csv|cut -d, -f5|tr ' ' $'\n'|sed '1s/^/^#[^#]\n/'|egrep -f- merge8.ann.vcf|cut -d$'\t' -f4,5,10-,8|sed -e 's/:[^\t]*//g' -e 's/\t/,/'|sed -E 's/\t([^\t]*)(.*)/\2\t\1/'|awk '{if (NR==1){$1="";print substr($0, 2)}else{a=$1;split(a,b,",");for(i=2;i<=NF-1;i++) { split($i, c, "/");printf b[c[1]+1]"/"b[c[2]+1]"\t" }print $NF}}'|sed '1s/_[^\t ]*./\t/g'|awk '$4==$6&&$4!=$1&&$4!=$2&&$4!=$3&&$4!=$5&&$4!=$7&&$4!=$8{print}{if(NR==1)print}'|grep -P '[^|]+(?=\|HIGH|INFO)'|cut -d$'\t' -f1-8
