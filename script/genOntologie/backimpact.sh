#!/bin/bash
# script om mutaties terug te halen vanuit genen
if test $# -eq 0;then
 select="$(eval kdialog --geometry 700x500  --checklist \"Kies een gen groep uit de lijst:\" $(cut -d, -f1,2 GO_HIGH_IMPACT_GROUPS.csv|sed 1\!p|tr \\n ' ')|sed 's/ *$//'|perl -pe 's/ (?=([^"\\]*(\\.|"([^"\\]*\\.)*[^"\\]*"))*[^"]*$)/\n/g')"
 [ "$select" = "" ]&& { echo Gebruiker sluit af;exit;}
 echo "$select"
 # echo "$select"|cut -d, -f2|grep -f- merge8.ann.vcf --color=yes
 # groep=$(echo "$select"|cut -d, -f2)
 #groep="Anatomical structure morphogenesis"
 qdbus org.kde.yakuake /yakuake/window toggleWindowState
 echo "$select"|cut -d, -f2|grep -f- GO_HIGH_IMPACT_GROUPS.csv|cut -d, -f3|cut -d\" -f2|tr ' ' $'\n'|sed '1s/^/^#[^#]\n/'|egrep -f- merge8.ann.vcf --color=yes|grep --color=no HIGH
 echo "$select"|cut -d, -f2|grep -f- GO_HIGH_IMPACT_GROUPS.csv|cut -d, -f3|cut -d\" -f2|tr ' ' $'\n'|sed '1s/^/^#[^#]\n/'|egrep -f- merge8.ann.vcf --color=yes|grep --color=no HIGH|cut -d$'\t' -f1,2 > geselecteerde_snps.pos
else
  cut -d, -f2 "$1"|grep -f- GO_HIGH_IMPACT_GROUPS.csv|cut -d, -f3|cut -d\" -f2|tr ' ' $'\n'|sed '1s/^/^#[^#]\n/'|egrep -f- merge8.ann.vcf --color=yes|grep --color=no HIGH|cut -d$'\t' -f1,2 > geselecteerde_snps.pos
fi
scp geselecteerde_snps.pos naturalis:
ssh naturalis "Rscript pos2fasta.R"
echo "Even wachten tot BLAST is gestart"
ssh naturalis 'while test "" = "$(squeue|grep david)";do sleep 3;done;echo "blast draait...";while test "" != "$(squeue|grep david)";do sleep 3;done'
scp naturalis:$(ssh naturalis "ls -ht /data/david.noteborn/blast_output/*.fasta|head -1") geselecteerde_geblastte_snps.fasta
less geselecteerde_geblastte_snps.fasta
