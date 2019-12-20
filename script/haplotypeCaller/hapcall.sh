#!/bin/bash
# door david noteborn
# Naturalis
# superviced door Rutger Vos
# zal vanaf HOME directory
# van gecombineerde bam files
# varianten dmv gatk callen
# en in een vcf bestand zetten
# (dit gebeurd voor ieder gesampled individu)
cd "$HOME"
if false;then # zet dit op true als gatk al in je home directory staat
	# download gatk
	wget https://github.com/broadinstitute/gatk/releases/download/4.1.3.0/gatk-4.1.3.0.zip
	# unzip it
	unzip gatk-*.zip
	rm gatk-*.zip
fi
if false;then # zet dit op true als je al picard in je home directory hebt geplaatst
	wget https://github.com/broadinstitute/picard/releases/download/2.20.8/picard.jar
fi

norvegicus="REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered"
[ ! -e $norvegicus.fa ] && gunzip $norvegicus.fa.gz # als fasta nog niet is uitgepakt, pak het uit
# als er nog geen sequence dictionary is maak die
[ ! -e $norvegicus.dict ] && java -jar picard.jar CreateSequenceDictionary R=$norvegicus.fa
[ ! -e $norvegicus.fai ] && samtools faidx $norvegicus.fa # als het fasta bestand nog niet geindexeerd is indexeer
# haplotype calling
for x in ../rutger.vos/fileserver/projects/B19005-525/Samples/*;do
	if [ ! -e $x/${x##*/}.vcf ];then
		# run een sbatch job
		sbatch <<< '#!/bin/bash
# vervang de header sample naam (anders is gatk niet echt happy)
samtools addreplacerg -R NA -m overwrite_all '$x/${x##*/}'.bam -o '$x/${x##*/}'.gh.bam
mv '$x/${x##*/}'.gh.bam '$x/${x##*/}'.bam
# indexeer het gemaakte bestand
samtools index '$x/${x##*/}'.bam
# call variants
./gatk*/gatk HaplotypeCaller -R '$norvegicus.fa' -I '$x/${x##*/}'.bam -O '$x/${x##*/}'.vcf'
	fi
done
