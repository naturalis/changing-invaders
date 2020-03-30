# changing-invaders
Scripts and config files for assembly and SNP design of genomics of Polynesian rats

Veel scripts kosten wat tijd om te draaien. Mede hierdoor wordt gebruik gemaakt van het slurm systeem.
Dit is een systeem dat jobs beheert op een server. Vandaar dat de meeste (bash)scripts in deze repository gebruik maken van sbatch en de volgende structuur:
```bash
#!/bin/bash
# wat het script doet
code om de argumenten te verwerken of op standaard waarden te zetten
[ $# -gt 0 ]&&variable1=$1||variable1=standaard_argument
code die kijkt of de bestandsargumenten daadwerkelijk aanwezig zijn
if test $(dat het geval is);then
 sbatch <<< '#!/bin/bash
  # daadwerkelijke code
  programma_a "'"$variable1"'"
'
fi
```
Let hierbij op dat sbatch het programma is waarmee jobs bekend worden gemaakt op de server. Het programma dat de job dus inhoud staat dan vervolgens op de volgende regels.
Omdat er wordt gewerkt met '(enkele quote) zullen argumenten die worden meegegeven vaak staan binnen "'" (dubbelle quote zodat de meeste variabelen spaties kunnen bevatten)

Voor alle scripts voor de cleanup verwijs ik naar: https://github.com/naturalis/changing-invaders/tree/922c543dcc55c43b1ed627e0396ae57dc107ad10
