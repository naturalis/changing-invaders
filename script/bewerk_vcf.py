#!/usr/bin/python3
# dit script bewerkt het vcf bestand voor het wordt opgeslagen in een database
# door David Noteborn
# changing invaders
# de afstand kolommen geven -1 aan als afstand niet bepaald kan worden
# (geen andere snps meer op dat chromosoom)
import sys
import gzip

if len(sys.argv) > 1:
	vcf = sys.argv[1]
else:
	vcf = 'testdb.vcf'
if len(sys.argv) > 2 and sys.argv[2]=="gzip":
	gzipped = True
	db = gzip.open(vcf, 'rb')
else:
	gzipped = False
	db = open(vcf, 'r')
def notperiod(x):
	if x == ".":
		return ""
	else:
		return x

def unconstruct(info, data):
	try:
		if info[-1]=="SB":
			if info[-2]=="PL":
				return data
			else:
				return data[0:4] + [data[-3], data[-1]] # physical phasing
		else:
			if info[-1]=="PS" or len(info) == 3:
				return [data[0], "", "", "", "", ""]
			else:
				return [data[0]] + [''] + data[1:3] + [data[4]] + [""]
	except:
		print(info)

semi_oud = ""
for regel in db:
	if gzipped:
		regel = regel.decode('utf-8')
	if regel[0:2] == "##":
		pass
	elif regel[0:1] == "#":
		if False:
			regel = [notperiod(x) for x in regel.split("\t")]
			print("\t".join(regel[0:8] + [regel[9].strip() + "_" + x for x in ['GT', 'AD', 'DP', 'GQ', 'PL', 'SB']] + ['SNP_SIZE']))
	else:
		regel = [notperiod(x) for x in regel.split("\t")]
		if semi_oud == "":
			regel += "\t" + "-1"
		else:
			if regel[0]==semi_oud[0]:
				regel += [str(int(regel[1]) - int(semi_oud[1]))]
				semi_oud += [str(int(regel[1]) - int(semi_oud[1]))]
			else:
				regel += ["-1"]
				semi_oud += ["-1"]
			if len(semi_oud) > 3:
				print("\t".join(semi_oud))
		if len(regel[8].split(":")) > 1:
			semi_oud = regel[0:8] + \
			unconstruct(regel[8].split(":"), regel[9].strip().split(':')) + \
				[str(max([len(x) for x in regel[4].split(',')]))] + [regel[-1]]
		else:
			semi_oud = ["", regel[1]]
# print de laatste regel
print("\t".join(semi_oud + ["-1"]))
