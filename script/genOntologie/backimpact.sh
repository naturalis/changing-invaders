#!/bin/bash
# changing invaders
# script om mutaties terug te halen vanuit genen
# dit vanuit de GO-term selectie van de gebruiker
# flanking regions worden vervolgens ge-extraheert uit
# het referentie genoom en worden vervolgens geBLAST, en
# enkel als het slechts 1 keer voor komt in het genoom, wordt
# het weergegeven op gescherm en opgeslagen
#
# als er geen argument vanuit de commandline wordt meegegeven
if test $# -eq 0;then
 # laat een gebruiker kiezen in een dialoogvenster tussen alle HIGH impact groepen
 # neem het aantal genen binnen de ontologische groep, en de groep zelf
 # verdubbel iedere regel (behalve de eerste, verwijder die)
 # dit omdat de waarde die wordt weergeven in kdialog een andere is dan de waarde die wordt teruggekeerd.
 # zet alles op 1 regel gescheiden door spaties
 # als de gebruiker gekozen heeft, verwijder dan de spatie aan het einde, en vervang iedere
 # spatie die niet tussen twee " staat door een nieuwe regel
 # en stop het resultaat (een lijst met ontologische groepen met daarvoor een getal in select)
 select="$(eval kdialog --geometry 700x500  --checklist \"Kies een gen groep uit de lijst:\" $(cut -d, -f1,2 GO_HIGH_IMPACT_GROUPS.csv|sed -n '1!p;s/.*/&\noff/p'|tr \\n ' ')|sed 's/ *$//'|perl -pe 's/ (?=([^"\\]*(\\.|"([^"\\]*\\.)*[^"\\]*"))*[^"]*$)/\n/g')"
 # als het niks is sluit dan af
 [ "$select" = "" ]&& { echo Gebruiker sluit af;exit;}
 echo "$select"
 # echo "$select"|cut -d, -f2|grep -f- merge8.ann.vcf --color=yes
 # groep=$(echo "$select"|cut -d, -f2)
 #groep="Anatomical structure morphogenesis"
 # klap de opvouwbare terminal uit
 qdbus org.kde.yakuake /yakuake/window toggleWindowState
 # zoek alle ontologische groepen (de getallen er eerst af halend) in het HIGH impact bestand
 # neem daarvan slechts de derde kolom (de genen, gescheiden op spaties)
 # de genen zitten nu tussen twee " dus neem enkel de genen, en zet ieder op een eigen regel
 # voeg voor het eerste gen een patroon toe wat als eerste karakter op een regel # matched, dan alles
 # behalve #. Zoek dit alles in merge8.ann.vcf (vcf bestand), en neem nu enkel de rijen die HIGH impact
 # hebben en laat die zien
 echo "$select"|cut -d, -f2|grep -f- GO_HIGH_IMPACT_GROUPS.csv|cut -d, -f3|cut -d\" -f2|tr ' ' $'\n'|sed '1s/^/^#[^#]\n/'|egrep -f- merge8.ann.vcf --color=yes|grep --color=no -E 'HIGH|#'
 # doe het bovenstaande, behalve het niet meenemen van de header
 # gevolgd door enkel de eerste twee velden mee te nemen (chromosoom en positie)
 # en dit op te slaan in geselecteerde_snps.pos
 echo "$select"|cut -d, -f2|grep -f- GO_HIGH_IMPACT_GROUPS.csv|cut -d, -f3|cut -d\" -f2|tr ' ' $'\n'|egrep -f- merge8.ann.vcf|grep HIGH|cut -d$'\t' -f1,2 > geselecteerde_snps.pos
else
 # als er wel een commandline argument is meegegeven, gebruik dit in plaats van select
 # en doe hetzelfde als het bovenstaande
  cut -d, -f2 "$1"|grep -f- GO_HIGH_IMPACT_GROUPS.csv|cut -d, -f3|cut -d\" -f2|tr ' ' $'\n'|egrep -f- merge8.ann.vcf|grep HIGH|cut -d$'\t' -f1,2 > geselecteerde_snps.pos
fi
# kopieer geselecteerde_snps.pos naar de naturalis server
scp geselecteerde_snps.pos naturalis:
# start het script dat uit het referentie genoom een fasta maakt en dat BLAST door middel van een ander script. Als dat gebeurt, zal het script zelf al zijn gestopt
ssh naturalis "Rscript pos2fasta.R"
echo "Even wachten tot BLAST is gestart"
# wacht tot BLAST te zien is in squeue, wacht daarna tot het niet meer te zien is (en het BLASTen dus klaar is)
ssh naturalis 'while test "" = "$(squeue|grep david)";do sleep 3;done;echo "blast draait...";while test "" != "$(squeue|grep david)";do sleep 3;done'
# kopieer het laatst geBLASTte bestand terug naar de lokale machine
scp naturalis:$(ssh naturalis "ls -ht /data/david.noteborn/blast_output/*.fasta|head -1") geselecteerde_geblastte_snps.fasta
# laat het bestand aan de gebruiker zien
less geselecteerde_geblastte_snps.fasta
