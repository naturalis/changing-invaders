# BLAST SNP flanking regions

To know whether a SNP would be a good candidate for KASP, the flanking regions of the SNP are BLASTed against consensus genomes. First the filtered SNP flanking regions should be extracted as fasta (uniek-meer.R). Then BLASTing is done. This is done by two scripts. However because one can BLAST against all consensus genomes at once, or just one, two scripts are made: blast_primers.sh (for one consensus genome) and blast_all_primers.sh (for BLASTing all consensus genomes). blast_output.R is the second script that checks whether an alignment actually contains a INDEL (insetion/deletion), since primers will not align with gaps. (As one can see this is a bit too conservative and actually might have a way bigger gap cost to resolve this problem).
See also the flowchart:
![flowchart](../../doc/flowchart/blastSNPs.png?raw=true)
