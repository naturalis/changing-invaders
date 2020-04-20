#!/usr/bin/perl
# changing invaders
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
if (defined $index) {
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

        # $final_stem is to deposit the final result (i.e. the merge across the samples) in storage
        # $tmp_stem is for the intermediate steps, which are staged on faster media
        my $final_stem  = "${outdir}/${sample}-${run}";
        my $tmp_stem    = $ws->stage($final_stem);
        my $tmp_bam     = "${tmp_stem}.bam";
        if ( not -e $tmp_bam ) {

            # minimap2 arguments:
            # -ax sr    short reads
            # -a        out format SAM
            # -t 4      threads
            # REF R1 R2 > out.sam
            my $mm2 = "minimap2 -ax sr -a -t $threads $staged_ref_file $staged_r1 $staged_r2 > ${tmp_stem}.sam";
            INFO "Going to map reads with: '$mm2'";
            system($mm2) == 0 or die $?;
            unlink($staged_r1, $staged_r2);

            # $infile gets re-assigned after every iteration
            my $infile = "${tmp_stem}.sam";
            for my $op ( qw(view fixmate sort markdup) ) {

                # intermediate files become *.view.bam, *.fixmate.bam, *.sort.bam, *.markdup.bam
                my $outfile = do_bam_thing(
                    operation => $op,
                    infile    => $infile,
                    outfile   => "${tmp_stem}.${op}.bam",
                );
                unlink($infile);
                $infile = $outfile;

                # markdup is final iteration, rename outfile to add it to the merging pile
                if ( $op eq 'markdup' ) {
                    system( "mv $outfile $tmp_bam" );
                    INFO "Done doing the BAM things, $tmp_bam goes on the merging pile";
                }
            }
        }
        else {
            INFO "Already mapped $tmp_bam";
        }
        push @bams_to_merge, $tmp_bam;
    }

    # merge the files for this sample all under the same sample (SM) read group (RG)
    my $RG = "\@RG\tID:NA\tSM:${sample}\tPL:ILLUMINA\tPI:NA";
    my $merge_command = "samtools merge -r '$RG' -l 9 --threads ${threads} ${outdir}/${sample}.bam @bams_to_merge";
    INFO "Going to merge BAM files with '$merge_command'";
    system($merge_command) == 0 or die $?;
    unlink(@bams_to_merge);
    $config->runs_for_sample( sample => $sample, type => 'bam', list => [ "${outdir}/${sample}.bam" ] );
}

print $config->to_string;

sub do_bam_thing {
    my %args = @_;
    my ( $operation, $infile, $outfile ) = @args{qw[operation infile outfile]};

    # command template, can use sprintf( $tmpl, $threads, $infile, $outfile ) on all of them
    my %OI_ops = (
        'view'    => 'samtools view -b -u -F 0x04 --threads %i -o %s %s', # 0 -b (bam) -u (uncompressed) -F 0x04 (filter unmapped)
        'sort'    => 'samtools sort -l 0 -m 7G --threads %i -o %s %s',    # 2 -m 6G = mem per thread
    );
    my %IO_ops = (
        'fixmate' => 'samtools fixmate -r -m  --threads %i %s %s',        # 1 -r    = rm unmapped reads and 2ary alignments
        'markdup' => 'samtools markdup -r --threads %i %s %s',            # 3 -r    = rm duplicates
    );

    # only do the thing if there's no outfile yet
    if ( not -e $outfile ) {

        # create command
        my $command;
        if ( $OI_ops{$operation} ) {
            $command = sprintf( $OI_ops{$operation}, $threads, $outfile, $infile );
        }
        elsif ( $IO_ops{$operation} ) {
            $command = sprintf( $IO_ops{$operation}, $threads, $infile, $outfile );
        }
        else {
            FATAL "No such operation known: $operation";
        }

        # do the thing
        INFO "Going to $operation BAM file with: $command";
        if (system($command) != 0) {
            FATAL "'$command': $?";
            die;
        }
    }
    else {
        WARN "Expected output file ($outfile) already exists, won't overwrite";
    }
    return $outfile;
}