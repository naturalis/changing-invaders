#!/usr/bin/python3
# changing invaders
# by David
# this script edits the vcf file and filters out all rows that do not comply the threshold
# the output (stdout) is the edited file
# example run
# sbatch_do 'bcftools view /data/d*.n*/merge8.bcf | python3 $HOME/combined2FoCaPSNPs.py | bcftools view -Ob > $HOME/merge8.bcf'
import sys

nlines = 0
for line in sys.stdin:
	# if it comprend a header line, show anyway
	if line[0:1] == "#":
		print(line, end = '')
	else:
		line = line.split("\t")
		depth = int([s for s in line[7].split(';') if "DP=" in s][0].split('=')[1])
		if depth > 16 and 110 > depth: # does the depth comply the threshold
			if float(line[5]) > 99: # does the quality comply the threshold
				line[2] = "SNP" + str(nlines)
				print("\t".join(line), end = '')
				nlines += 1

print(nlines, "written. nice.", file=sys.stderr)
