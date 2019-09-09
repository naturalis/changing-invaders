#!/usr/bin/perl
use strict;
use warnings;
use File::Spec;
use Getopt::Long;
use My::ChangingInvaders::Config;
use My::ChangingInvaders::WorkStage;
use Bio::Phylo::Util::Logger ':simple';

# process command line arguments
my $reference = 'Rnor_6.0-filtered';  # /Volumes/NGS/B19005-525/REF/Rattus_norvegicus.Rnor_6.0.dna.toplevel.filtered.fa.gz
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
    my $index_command = "minimap2 -d ${staged_ref_file}.mmi -t ${threads} ${staged_ref_file}";
    INFO "Going to index reference with: '$index_command'";
    system($index_command);
}

# here we iterate over the samples, i.e. each iteration is an individual
for my $sample ( sort { $a cmp $b } $config->samples ) {
    INFO "Going to start mapping sample $sample";

     # collect an array of bam files to merge
    my @bams_to_merge;

    # they have been sequenced multiple times in different runs
    for my $run ( sort { $a cmp $b } $config->runs_for_sample($sample) ) {

        # each run is paired end, so there is an R1 and an R2 file
        my ( $r1, $r2 ) = $config->files_for_run( sample => $sample, run => $run, type => 'fastp' );
        my ( $staged_r1, $staged_r2 ) = map { $ws->stage($_) } $r1, $r2;

        # minimap2 arguments: `-ax sr` (short reads), `-a` (out format BAM), `-t 4` (threads)
        # mapping arguments for the template: 1=threads, 2=ref, 3=R1, 4=R2, 5=out
        my $template    = "minimap2 -ax sr -a -t %i %s %s %s | samtools view -S -b - > %s.unsorted.bam";
        my $final_stem  = "${outdir}/${sample}-${run}";
        my $outfile     = $ws->stage($final_stem);
        my $map_command = sprintf( $template, $threads, $staged_ref_file, $staged_r1, $staged_r2, $outfile );
        INFO "Going to map reads with: '$map_command'";
        system($map_command);
        unlink($staged_r1, $staged_r2);

        # sort the reads in the BAM
        my $sort_command = "samtools sort ${outfile}.unsorted.bam -o ${outfile}.bam";
        INFO "Going to sort BAM file with: '$sort_command'";
        system($sort_command);
        unlink("${outfile}.unsorted.bam");
        push @bams_to_merge, "${outfile}.bam";
    }

    # XXX this will merge all the runs under a single 'read group' (i.e. sample)
    my $RG = "\@RG\tID:NA\tSM:${sample}\tPL:ILLUMINA\tPI:NA";

    # now merge the files for this sample
    my $merge_command = "samtools merge -r '$RG' ${outdir}/${sample}.bam @bams_to_merge";
    INFO "Going to merge BAM files with '$merge_command'";
    system($merge_command);
    unlink(@bams_to_merge);
    $config->runs_for_sample( sample => $sample, type => 'bam', list => [ "${outdir}/${sample}.bam" ] );
}

print $config->to_string;
