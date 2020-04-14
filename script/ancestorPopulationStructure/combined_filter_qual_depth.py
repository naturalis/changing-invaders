#!/usr/bin/python3
# changing invaders
# this script edits the vcf file and filters out all rows that do not comply the threshold
# the output (stdout) is the edited file
# by David
# example run
# sbatch_do 'bcftools view /data/d*.n*/merge8.bcf | python3 $HOME/combined_filter_qual_depth.py | bcftools view -Ob > $HOME/merge8.bcf'
import sys

nregels = 0
for regel in sys.stdin:
	# if it comprend a header line, show anyway
	if regel[0:1] == "#":
		print(regel, end = '')
	else:
		regel = regel.split("\t")
		diepte = int([s for s in regel[7].split(';') if "DP=" in s][0].split('=')[1])
		if diepte > 16 and 110 > diepte: # does the depth comply the threshold
			if float(regel[5]) > 99: # does the quality comply the threshold
				regel[2] = "SNP" + str(nregels)
				print("\t".join(regel), end = '')
				nregels += 1

print(nregels, "written. nice.", file=sys.stderr)
