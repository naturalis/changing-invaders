#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use My::ChangingInvaders::Config;
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
    'outdir=s'    => \$outdir,
);

# setup services, data sources
my $config = My::ChangingInvaders::Config->new( '-file' => $yaml );
Bio::Phylo::Util::Logger->new( '-level' => $verbosity );

# index reference
my $ref_file = $config->file_for_reference($reference);
INFO "Going to index reference $reference with `bwa index $ref_file`";
system( "bwa index $ref_file" );

# here we iterate over the samples, i.e. each iteration is an individual
for my $sample ( $config->samples ) {
    INFO "Going to start mapping sample $sample";

    # XXX this tag is important for the subsequent GATK operations
    my $RG = "\@RG\tID:NA\tSM:${sample}\tPL:ILLUMINA\tPI:NA";
    my @bams_to_merge;

    # they have been sequenced multiple times in different runs
    for my $run ( $config->runs_for_sample($sample) ) {

        # each run is paired end, so there is an R1 and an R2 file
        my ( $r1, $r2 ) = $config->files_for_run( sample => $sample, run => $run, type => 'fastp' );

        # do the mapping, include the @RG tag to identify samples when merging
        my $outfile = "${outdir}/${sample}-${run}";
        DEBUG "Going to run BWA-MEM for $outfile";
        system("bwa mem -R $RG -t $threads $reference $r1 $r2 > ${outfile}.sam");

         # convert to BAM
        DEBUG "Going to run samtools view (i.e. SAM => BAM) for $outfile";
        system("samtools view -S -b ${outfile}.sam > ${outfile}.unsorted.bam");
        unlink("${outfile}.sam");

        # sort the reads in the BAM
        DEBUG "Going to run samtools sort (i.e. for merging) for $outfile";
        system("samtools sort ${outfile}.unsorted.bam -o ${outfile}.bam");
        unlink "${outfile}.unsorted.bam";
        push @bams_to_merge, "${outfile}.bam";
        $config->files_for_run( sample => $sample, run => $run, type => 'bam', list => ["${outfile}.bam"] );
    }

    # now merge the files for this sample
    INFO "Finalizing sample $sample by merging mapped runs: @bams_to_merge";
    system("samtools merge -r $RG ${outdir}/${sample}.bam @bams_to_merge");
    $config->runs_for_sample( sample => $sample, type => 'bam', list => [ "${outdir}/${sample}.bam" ] );
}

print $config->to_string;
