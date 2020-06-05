#!/usr/bin/python3
# changing invaders
# by David
# this script edits the vcf file before it is saved inside a database
# the distances display -1 if the distance can not be determined
# this distance might be incorrect
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
		print(info)

semi_old = ""
if len(sys.argv) > 1:
	getal = sys.argv[1]
else:
	print("No number given (required for the last column).")
	sys.exit()

for line in sys.stdin:
	if line[0:2] == "##":
		pass
	elif line[0:1] == "#":
		if False:
			line = [notPeriod(x) for x in line.split("\t")]
			print("\t".join(line[0:8] + [line[9].strip() + "_" + x for x in ['GT', 'PL-R', 'PL-H', 'PL-A']] + ['SNP_SIZE']))
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
				semi_old += [getal]
				print("\t".join(semi_old))
		if len(line[8].split(":")) > 1:
			# the info column is here but the depth
			possibilities = [line[3]] + line[4].split(",")
			before, after = line[9].strip().split(':')[[idx for idx, s in enumerate(line[8].split(":")) if 'GT' in s][0]].split("/")
			semi_old = line[0:2] + line[3:6] + \
			[[s for s in line[7].split(';') if "DP=" in s][0].split('=')[1]] + \
			unConstruct(line[8].split(":"), line[9].strip().split(':')) + [possibilities[int(before)] + "/" + possibilities[int(after)], line[-1]]
		else:
			semi_old = ["", line[1]]
# print the last line
semi_old += ["-1", getal]
print("\t".join(semi_old))
