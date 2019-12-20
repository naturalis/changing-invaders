# steps to SNPs
* fastp.pl
  - By the use of fastp reads are trimmed on quality. Every base on a read has a score for the chance of incorrect calling of that base. This score is known as Phred.
* minimap2
  - By the use of `minimap2` reads are aligned to the reference genome (Rattus Norvegicus) and these alignments are saved to BAM files (4 per organism for 4 runs each organism is sequenced) all files are sequenced in two directions(paired end), but these are used and combined in this step.
* before calling
  - Combine the 4 BAM files for each organims to 1 bam file, so there is 1 'huge' alignment of all reads per sample. Change the sample name of all reads to the same for each file, else HaplotypeCaller will fail to call. Sort the BAM files to make it easier to find reads mapped at a certain point at the genome.
* Calling
  - Variant Calling is a term for finding variants on the alignments.
  - Calling of variants is first tried with 'HaplotypeCaller'. The Cambodia sample has been successfully called with this method. HaplotypeCaller could be runned in paralell by the use of a Scala script and Queue, which will split the whole bam file up into specific genomic ranges so multiple HaplotypeCaller processes could process different genomic ranges alongside each other.
  - Calling is then done by the use of `bcftools`. There is explicitly stated to only find SNPs, so insertions/deletions of bases are not taken into account. The result of the calling was a bcf file (binary variant calling format). This is done for all samples, including Cambodia. bcftools is more complicated to paralelize, except for a small part of the algorithm.
* before database
  - The 8 bcf files are processed are read into a database. This database has columns based on the bcf/vcf file with the following modifications:
    - The id(3rd) column and the filter(7th) column are not in the database. These are for all records (or at least about 3 samples) empty.
    - The format column is for all records the same ('GT:PL') and is not in the database.
    - The info column is replaced with the depth of the reads.
    - Genotype and phred score for each genotype are two seperate columns.
    - After these columns there are two columns describing the distance between the previous and next SNP. If this is not available the values are rendered -1 (so are filtered out in some next step currently.)
    - At last there is a column containing a number referencing to the sample where it belongs to. The table that contains information which numbers are mapped to which sample is called sample-enum.csv (on this github repository)
  - There is also a database created with only unique SNPs and the Genotype/Phred columns per sample.
* database
  - There is filtered on multiple ways:
    - Is it homozygote, so is the SNP fully shared over all 8 organisms? If that is the case, the SNP will not detect much.
    - Is the general phred quality score higher than 99?
    - Is the number of reads on the position of the SNP (*coverage*) greater than 16 and smaller than 110?
    - Is there no other SNP 300 bases upstream or downstream?
  - All those conditions must be true to keep the SNP.
  - The chromosome/position pairs that are belong to genuine SNPs according to the filter steps are saved as a file, and later as a table in the database.
  - These SNPs are then fully exported to a file on disk.
* Consensus genome
  - Consensus genomes of the rats are made by calling all types of variants for a bam file, and use these variants.
* BLASTing
  - The sequence of 250 bases before, and after the SNP is collected from the reference genome(*R. Norvegicus*), and BLASTed against all the constructed consensus genomes of the 8 rats. The SNPs belonging to sequences which are matched more than one, or zero times, are rejected.
[Filter steps image][https://raw.githubusercontent.com/naturalis/changing-invaders/master/filterStap.png?token=ANKL234X5VYRSAE4RBEXL6C6AXKGS]
