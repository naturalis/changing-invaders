# BLASTing

De SNPs locaties zijn opgeslagen als filtered_snps.csv. Door middel van dna_van_ref.R zal een csv bestand gemaakt worden met de positites, en de 250 basen voor en na de SNP (en daarnaast de SNP ref allele zelf)
Door middel van de sed expressie
`sed -nE '1!{s/([0-9]+,[0-9]+),"([^"]+)","([^"]+)","(.)"/>\1-\4\n\2\n>\1-\4\n\3/p}' filtered_snps_seq.csv > filtered_snps_seq.fasta`
wordt een fasta bestand aangemaakt met de voor/na sequentie(s) als losse records.
Dit fasta bestand kan worden gebruikt door blast_primers.sh om de sequenties te zoeken in een genoom.
Dit kan door het script `blast_primers.sh`.
De output is een bestand dat bijna json is. (afgezien van een datum aan het einde)
Het zoekt 20 hits (met 20 HSP). Het is bekend dat dit niet per ce de beste 20 hits zijn (door paper), maar dat is voor het gebruik van het zoeken voor primers niet belangrijk.
Ook hoort bij de output een fasta bestand `filtered_snps_(korte sample naam).fasta` met alle sequenties die exact 1 keer voor kwamen.
Dit bestand kan vervolgens weer gebruikt worden om opnieuw te BLASTen met een ander consensus genoom.
