#!/usr/bin/python3
# dit script bewerkt het vcf bestand voor het wordt opgeslagen in een database
# door David Noteborn
# changing invaders
# de afstand kolommen geven -1 aan als afstand niet bepaald kan worden
# (geen andere snps meer op dat chromosoom)
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

semi_oud = ""
if len(sys.argv) > 1:
	getal = sys.argv[1]
else:
	print("Geen getal gegeven (nodig voor laatste kolom).")
	sys.exit()

for regel in sys.stdin:
	if regel[0:2] == "##":
		pass
	elif regel[0:1] == "#":
		if False:
			regel = [notperiod(x) for x in regel.split("\t")]
			print("\t".join(regel[0:8] + [regel[9].strip() + "_" + x for x in ['GT', 'PL-R', 'PL-H', 'PL-A']] + ['SNP_SIZE']))
	else:
		regel = [notperiod(x) for x in regel.split("\t")]
		if semi_oud == "":
			regel += ["-1"]
		else:
			if regel[0]==semi_oud[0]:
				regel += [str(int(regel[1]) - int(semi_oud[1]))]
				semi_oud += [str(int(regel[1]) - int(semi_oud[1]))]
			else:
				regel += ["-1"]
				semi_oud += ["-1"]
			if len(semi_oud) > 3:
				#if semi_oud[-5] == "" or semi_oud[-5] == xyz:  # Phred-scaled genotype likelihoods
				semi_oud += [getal]
				print("\t".join(semi_oud))
		if len(regel[8].split(":")) > 1:
			# de info kolom is hier slechts de diepte
			mogelijkheden = [regel[3]] + regel[4].split(",")
			voor, na = regel[9].strip().split(':')[[idx for idx, s in enumerate(regel[8].split(":")) if 'GT' in s][0]].split("/")
			semi_oud = regel[0:2] + regel[3:6] + \
			[[s for s in regel[7].split(';') if "DP=" in s][0].split('=')[1]] + \
			unconstruct(regel[8].split(":"), regel[9].strip().split(':')) + [mogelijkheden[int(voor)] + "/" + mogelijkheden[int(na)], regel[-1]]
		else:
			semi_oud = ["", regel[1]]
# print de laatste regel
semi_oud += [getal]
print("\t".join(semi_oud + ["-1"]))
