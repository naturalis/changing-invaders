#!/usr/bin/perl
use strict;
use warnings;
use File::Spec;
use Getopt::Long;
use My::ChangingInvaders::Config;
use My::ChangingInvaders::WorkStage;
use Bio::Phylo::Util::Logger ':simple';

# process command line arguments
my $reference = 'Rnor_6.0';  # ./reference/Brassica_oleracea.v2.1.dna.toplevel.chromosomes.fa
my $threads = 4;             # threads for BWA
my $yaml;                    # config file with data locations per sample
my $verbosity = WARN;        # verbosity
my $outdir;                  # directory where to write BAM files
my $index;                   # whether to index the reference
my $workdir = $ENV{HOME} . '/tmp'; # dir where to do the analysis
GetOptions(
    'reference=s' => \$reference,
    'threads=i'   => \$threads,
    'yaml=s'      => \$yaml,
    'verbose+'    => \$verbosity,
    'outdir=s'    => \$outdir,
    'index'       => \$index,
    'workdir=s'   => \$workdir,
);

# setup services, data sources
my $ws = My::ChangingInvaders::WorkStage->new($workdir);
my $config = My::ChangingInvaders::Config->new( '-file' => $yaml );
Bio::Phylo::Util::Logger->new( '-level' => $verbosity );

# lookup reference file, possibly index
my $ref_file = $config->file_for_reference($reference);
my $staged_ref_file = $ws->stage($ref_file);
if ( $index ) {
    INFO "Going to index reference $reference with `bwa index $staged_ref_file`";
    system("bwa index -a bwtsw $staged_ref_file");
}

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
        my ( $staged_r1, $staged_r2 ) = map { $ws->stage($_) } $r1, $r2;

        # do the mapping, include the @RG tag to identify samples when merging
        my $final_stem = "${outdir}/${sample}-${run}";
        my $outfile = $ws->stage($final_stem);
        DEBUG "Going to run BWA-MEM for $outfile";
        system("bwa mem -M -v 2 -t $threads $staged_ref_file $staged_r1 $staged_r2 > ${outfile}.sam");
        unlink($staged_r1, $staged_r2);

         # convert to BAM
        DEBUG "Going to run samtools view (i.e. SAM => BAM) for $outfile";
        system("samtools view -S -b ${outfile}.sam > ${outfile}.unsorted.bam");
        unlink("${outfile}.sam");

        # sort the reads in the BAM
        DEBUG "Going to run samtools sort (i.e. for merging) for $outfile";
        system("samtools sort ${outfile}.unsorted.bam -o ${outfile}.bam");
        push @bams_to_merge, "${outfile}.bam";
        unlink("${outfile}.unsorted.bam");
    }

    # now merge the files for this sample
    INFO "Finalizing sample $sample by merging mapped runs: @bams_to_merge";
    system("samtools merge -r $RG ${outdir}/${sample}.bam @bams_to_merge");
    $config->runs_for_sample( sample => $sample, type => 'bam', list => [ "${outdir}/${sample}.bam" ] );
    unlink(@bams_to_merge);
}

print $config->to_string;
