#!/bin/bash
# changing invaders
# script to obtain mutations back from genes
# this from the GO-term selection from the user
# flanking regions will be extracted from
# the reference genome and will be BLASTed, and
# only when it occurs only once on the genome,
# it will be displayed on the screen and saved
# this script assumes that a distant blast dedicated server has ssh access
# which is defined as naturalis and where in the home directory lies the files
# pos2fasta.R and blast_all_primers_no_remove.sh also /data/d*.n*/ (should be modified to)
# represent the directory where the BLAST script outputs
# this script also assumes that the user uses yakuake as the terminal
#
# if there is no argument added from the commandline
if test $# -eq 0;then
 # allow a user to choose in a dialog on all HIGH impact groups
 # get the number of genes within the ontological group and the name of the group itself
 # duplicate every line (execpt for the first, remove that one)
 # this becuase the value that is added in kdialog is another than the value that is 'returned'.
 # put everything on one line, seperated by spaces.
 # if the user has chosen, remove the space on the end, and replace every
 # space that is not inbetween two " by a newline
 # and put the result (a list with ontological groups, preceded by a number in select)
 select="$(eval kdialog --geometry 700x500  --checklist \"Choose a gene group from the list:\" $(cut -d, -f1,2 GO_HIGH_IMPACT_GROUPS.csv|sed -n '1!p;s/.*/&\noff/p'|tr \\n ' ')|sed 's/ *$//'|perl -pe 's/ (?=([^"\\]*(\\.|"([^"\\]*\\.)*[^"\\]*"))*[^"]*$)/\n/g')"
 # if it is nothing exit the appliction
 [ "$select" = "" ]&& { echo User exits;exit;}
 echo "$select"
 # open up the foldable terminal (only when one has yakuake)
 qdbus org.kde.yakuake /yakuake/window toggleWindowState
 # search all ontological groups (first removing the numbers) in the HIGH impact file
 # get from that only the third column (genes, seperated on spaces)
 # the genes are now betweeen two " so get only the genes, and put every single one on a single line
 # add before the first gene a pattern which match as first character on a line a # and then all but #.
 # Search this all in merge8.ann.vcf (vcf file), and get now only the rows that have HIGH impact
 # and show them
 echo "$select"|cut -d, -f2|grep -f- GO_HIGH_IMPACT_GROUPS.csv|cut -d, -f3|cut -d\" -f2|tr ' ' $'\n'|sed '1s/^/^#[^#]\n/'|egrep -f- merge8.ann.vcf --color=yes|grep --color=no -E 'HIGH|#'
 # do the previous written, except not getting the header
 # followed by getting only the first two fields (chromosome and position)
 # and save this in selected_snps.pos
 echo "$select"|cut -d, -f2|grep -f- GO_HIGH_IMPACT_GROUPS.csv|cut -d, -f3|cut -d\" -f2|tr ' ' $'\n'|egrep -f- merge8.ann.vcf|grep HIGH|cut -d$'\t' -f1,2 > selected_snps.pos
else
 # if there is added a command-line argument, use that instead of select
 # and do that same as above
  cut -d, -f2 "$1"|grep -f- GO_HIGH_IMPACT_GROUPS.csv|cut -d, -f3|cut -d\" -f2|tr ' ' $'\n'|egrep -f- merge8.ann.vcf|grep HIGH|cut -d$'\t' -f1,2 > selected_snps.pos
fi
# copy selected_snps.pos to the naturalis server
scp selected_snps.pos naturalis:
# start the script that extracts fastas from the data out of the reference genome and BLAST by means of another script. If that happens, the script itself is already stopped
ssh naturalis "Rscript pos2fasta.R"
echo "Please wail a few seconds until BLAST is started"
# wait until BLAST is visible in squeue, wait then until it is no longer visible (and the BLASTing is done)
ssh naturalis 'while test "" = "$(squeue|grep david)";do sleep 3;done;echo "BLAST runs...";while test "" != "$(squeue|grep david)";do sleep 3;done'
# copy the last BLASTed file back to the local machine
scp naturalis:$(ssh naturalis "ls -ht /data/d*.n*/blast_output/*.fasta|head -1") selected_blasted_snps.fasta
# show the file to the user
less selected_blasted_snps.fasta
