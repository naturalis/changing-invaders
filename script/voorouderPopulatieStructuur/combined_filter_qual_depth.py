#!/usr/bin/python3
# dit script bewerkt het vcf bestand en filtert alle rijen die niet voldoen aan de threshold eruit
# de uitvoer is het bewerkte bestand
# door David
# changing invaders
# sbatch_do 'bcftools view /data/david.noteborn/merge8.bcf | python3 $HOME/combined_filter_qual_depth.py | bcftools view -Ob > $HOME/merge8.bcf'
import sys

nregels = 0
for regel in sys.stdin:
	# als het een header regel omvat, laat sowieso zien
	if regel[0:1] == "#":
		print(regel, end = '')
	else:
		regel = regel.split("\t")
		diepte = int([s for s in regel[7].split(';') if "DP=" in s][0].split('=')[1])
		if diepte > 16 and 110 > diepte: # is de diepte binnen de threshold
			if float(regel[5]) > 99: # is de kwaliteit binnen de threshold
				regel[2] = "SNP" + str(nregels)
				print("\t".join(regel), end = '')
				nregels += 1

print(nregels, "geschreven. Wat fijn.", file=sys.stderr)
