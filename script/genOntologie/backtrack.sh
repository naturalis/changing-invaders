#!/bin/bash
# changing invaders
# script om mutaties terug te halen vanuit genen vanuit GO groep(en) die de
# gebruiker interessant vindt
#
# neem de significantie waardes, en de GO termen en dupliceer die
# (behalve de eerste regel) en voeg off daaraan toe (om aan te geven
# dat die groep standaard uit staat, tot de gebruiker er op klikt)
# en zet alles op eenzelfde regel, gescheiden door een spatie
# laat de gebruiker nu een groep kiezen
# en sla dat op in select
select="$(eval echo $(eval kdialog --geometry 700x500  --checklist \"Kies een gen groep uit de lijst:\" $(cut -d, -f1,4 GO_BIOLOGICAL_PROCESS_enrichment_ALL.csv|sed -n '1!{p;s/.*/&\noff/p}'|tr \\n ' ') leeg))"
[ "$select" = "leeg" ]&& { echo Gebruiker sluit af;exit;}
# scheidt select op , dus neem enkel de GO term
groep="$(echo "$select"|cut -d, -f2)"
#groep="Anatomical structure morphogenesis"
# klap de terminal uit
qdbus org.kde.yakuake /yakuake/window toggleWindowState
# zoek de GO term groep in GO_BIOLOGICAL_PROCESS_enrichment_ALL.csv,
# en neem vervolgens de genen (kolom 5), die ieder op een aparte regel worden gezet
# voeg aan het begin en het einde van iedere regel \| toe zodat het in regex |gennaam| matched
# voeg voor het eerste gen een regex toe die aangeeft dat de header-regel met de samplenamen
# erin matched, zoek dan alles wat matched in het geannoteerde vcf bestand
# neem van het vcf bestand enkel de basen, en sample informatie (voor de genotypes)
# behoudt nu enkel de genotypes van de sample informatie, en voeg de basen samen tot een
# komma gescheiden lijst
# vervolgens wordt van de header het eerste veld verwijderd, en wordt het vanaf het tweede veld
# weergegeven. voor alle overige rijen wordt het genotype in basen berekend per sample
# als het een homozygoot genotype is wordt dit als een base weergevn
# waarna de basen gekleurd worden en de samplenaam wordt afgekort tot het deel voor de _
# en alles naar het scherm wordt weergegeven
grep "$groep" GO_BIOLOGICAL_PROCESS_enrichment_ALL.csv|cut -d, -f5|xargs echo|tr ' ' $'\n'|sed -E 's/^|$/\\|/g'|sed '1s/^/^#[^#]\n/'|egrep -f- merge8.ann.vcf|cut -d$'\t' -f4,5,10-|sed -e 's/:[^\t]*//g' -e 's/\t/,/'|awk '{if (NR==1){$1="";print substr($0, 2)}else{a=$1;split(a,b,",");for(i=2;i<=NF;i++) { split($i, c, "/");printf b[c[1]+1]"/"b[c[2]+1]"\t" }print ""}}'|sed 's!\(.\)/\1!\1!g'|sed -E \
-e $'1!s/A/\033[1;31m&\033[0m/g' \
-e $'1!s/C/\033[1;32m&\033[0m/g' \
-e $'1!s/G/\033[1;33m&\033[0m/g' \
-e $'1!s/T/\033[1;34m&\033[0m/g' \
|sed '1s/_[^\t ]*./\t/g'|less
