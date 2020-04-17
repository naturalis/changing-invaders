#!/bin/bash
# changing invaders
# script to extract mutations out of genes from GO group(s) that
# gets the users interest
#
# get the significance values, and the GO terms and duplicate these
# (execpt for the first line) and add 'off' on them (to explain
# that te group is by default off, until the user clicks on it)
# and put everything on the same line, seperated by a space
# allow the user to choose a group
# and save that in select
select="$(eval echo $(eval kdialog --geometry 700x500  --checklist \"Kies een gen groep uit de lijst:\" $(cut -d, -f1,4 GO_BIOLOGICAL_PROCESS_enrichment_ALL.csv|sed -n '1!{p;s/.*/&\noff/p}'|tr \\n ' ') leeg))"
[ "$select" = "leeg" ]&& { echo Gebruiker sluit af;exit;}
# seperate select on , so only get the GO term
groep="$(echo "$select"|cut -d, -f2)"
#groep="Anatomical structure morphogenesis"
# fold yakuake open (foldable terminal)
qdbus org.kde.yakuake /yakuake/window toggleWindowState
# search the GO term group in GO_BIOLOGICAL_PROCESS_enrichment_ALL.csv,
# and get the genes (column 5), that are put on distict rows
# add to the begin and end ove every line \| so in regex it matches |gennaam|
# add before the first gene a regex that match the header-line with the samplenames
# in it, search then all what matched in the annotated vcf file
# get from the vcf file only the bases, and sample information (for the genotypes)
# keep now only the genotypes from the sample information, and add the bases together to a
# comma seperated list
# then from the header the first field is removed, and is show from the sencond field.
# For all other rows the genotype in basen is calculated per sample
# if it is a homozygote genotype then it will be displayed as a single base
# whereafter the bases are colored and the samplename is shorted to the part before the _
# and all is displayed to the screen
grep "$groep" GO_BIOLOGICAL_PROCESS_enrichment_ALL.csv|cut -d, -f5|xargs echo|tr ' ' $'\n'|sed -E 's/^|$/\\|/g'|sed '1s/^/^#[^#]\n/'|egrep -f- merge8.ann.vcf|cut -d$'\t' -f4,5,10-|sed -e 's/:[^\t]*//g' -e 's/\t/,/'|awk '{if (NR==1){$1="";print substr($0, 2)}else{a=$1;split(a,b,",");for(i=2;i<=NF;i++) { split($i, c, "/");printf b[c[1]+1]"/"b[c[2]+1]"\t" }print ""}}'|sed 's!\(.\)/\1!\1!g'|sed -E \
-e $'1!s/A/\033[1;31m&\033[0m/g' \
-e $'1!s/C/\033[1;32m&\033[0m/g' \
-e $'1!s/G/\033[1;33m&\033[0m/g' \
-e $'1!s/T/\033[1;34m&\033[0m/g' \
|sed '1s/_[^\t ]*./\t/g'|less
