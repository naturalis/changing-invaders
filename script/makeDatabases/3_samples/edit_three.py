#!/usr/bin/python3
# changing invaders
# by david
# this script edits the vcf file before it is saved in a database
# the istance columns display -1 if the distance can not be determined
# (no other SNPs on that chromosome)
import sys

def notperiod(x):
	if x == ".":
		return ""
	else:
		return x

def unconstruct(info, data):
	try:
		return data
	except:
		print(info)

semi_old = ""

for line in sys.stdin:
	if line[0:2] == "##":
		pass
	elif line[0:1] == "#":
		if False:
			line = [notperiod(x) for x in line.split("\t")]
			print("\t".join(line[0:8] + [line[9].strip() + "_" + x for x in ['GT', 'PL']] + ['SNP_SIZE']))
	else:
		line = [notperiod(x) for x in line.split("\t")]
		if semi_old == "":
			line += ["-1"]
		else:
			if line[0]==semi_old[0]:
				line += [str(int(line[1]) - int(semi_old[1]))]
				semi_old += [str(int(line[1]) - int(semi_old[1]))]
			else:
				line += ["-1"]
				semi_old += ["-1"]
			if len(semi_old) > 3:
				#if semi_old[-5] == "" or semi_old[-5] == xyz:  # Phred-scaled genotype likelihoods
				print("\t".join(semi_old))
		if len(line[8].split(":")) > 1:
			semi_old = line[0:2] + line[3:6] + line[7:8] + \
			unconstruct(line[8].split(":"), line[9].strip().split(':')) + \
			unconstruct(line[8].split(":"), line[10].strip().split(':')) + \
			unconstruct(line[8].split(":"), line[11].strip().split(':')) + [line[-1]]
		else:
			semi_old = ["", line[1]]
# print the last line
print("\t".join(semi_old + ["-1"]))
