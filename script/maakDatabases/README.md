# Maak Databases

De SNPs worden tijdelijk opgeslagen in een database, hier zijn verschillende scripts voor geschreven.
Op het huidige moment zijn de scripts vanuit `maak_snp_db.sh` het gebruike model.
`maak_snp.sql` bevat de tabel definities.
`voeg_bcf_toe.sql` voegt een tabel (vanaf stdin) toe (gescheiden op tab)
`bewerk_snp.py` bewerkt het vcf bestand zo dat het in de database past
`vulupos.sql` is een script dat alle unieke chromosoom/positie verbanden vult in de UPOS tabel van de database
