#!/usr/bin/perl
use strict;
use warnings;
use YAML::Syck;
use Getopt::Long;
use Bio::Phylo::Util::Logger ':simple';

# process command line arguments
my $reference;        # ./reference/Brassica_oleracea.v2.1.dna.toplevel.chromosomes.fa
my $threads = 4;      # threads for BWA
my $yaml;             # config file with data locations per sample
my $verbosity = WARN; # verbosity
my $outdir;           # directory where to write BAM files
GetOptions(
    'reference=s' => \$reference,
    'threads=i'   => \$threads,
    'yaml=s'      => \$yaml,
    'verbose+'    => \$verbosity,
);

# setup services, data sources
my $data = LoadFile($yaml);
Bio::Phylo::Util::Logger->new( '-level' => $verbosity )

# index reference
INFO "Going to index the reference genome with `bwa index $ref`";
system( "bwa index $ref" );

# do the mapping
for my $sample ( keys %$data ) {

	# do the mapping, include the @RG tag to identify samples when merging
	# XXX this tag is important for the subsequent GATK operations and the R script
	bwa mem \
		-R "@RG\tID:NA\tSM:${SM}\tPL:ILLUMINA\tPI:NA" \
		-t $threads \
		$reference \
		${SAMPLE}_R1.fastq.gz ${SAMPLE}_R2.fastq.gz \
		> ${SAMPLE}_pe.sam

	# convert to BAM
	samtools view -S -b ${SAMPLE}_pe.sam > ${SAMPLE}_pe.bam
	rm ${SAMPLE}_pe.sam

	# sort the reads in the BAM
	samtools sort ${SAMPLE}_pe.bam -o ${SAMPLE}_pe.sorted.bam
	rm ${SAMPLE}_pe.bam

	# index the BAM
	samtools index ${SAMPLE}_pe.sorted.bam
}
