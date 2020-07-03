#!/usr/bin/python3
# changing invaders
# by David
# this script edits the vcf file before it is saved inside a database
# the distance columns display -1 if distance could not be determined
# (no other SNP on that chromosome)
import sys

def notPeriod(x):
	if x == ".":
		return ""
	else:
		return x

def unConstruct(info, data):
	try:
		return data
	except:
		print("THIS:", info)

semi_old = ""

for line in sys.stdin:
	if line[0:2] == "##":
		pass
	elif line[0:1] == "#":
		if False:
			line = [notPeriod(x) for x in line.split("\t")]
			print("\t".join(line[0:8] + [line[9].strip() + "_" + x for x in ['GT', 'PL']] + ['SNP_SIZE']))
	else:
		line = [notPeriod(x) for x in line.split("\t")]
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
			unConstruct(line[8].split(":"), line[9].strip().split(':')) + \
			unConstruct(line[8].split(":"), line[10].strip().split(':')) + \
			unConstruct(line[8].split(":"), line[11].strip().split(':')) + \
			unConstruct(line[8].split(":"), line[12].strip().split(':')) + \
			unConstruct(line[8].split(":"), line[13].strip().split(':')) + \
			unConstruct(line[8].split(":"), line[14].strip().split(':')) + \
			unConstruct(line[8].split(":"), line[15].strip().split(':')) + \
			unConstruct(line[8].split(":"), line[16].strip().split(':')) + [line[-1]]
		else:
			semi_old = ["", line[1]]
# print the last line
print("\t".join(semi_old + ["-1"]))
