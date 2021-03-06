#!/usr/bin/perl
# changing invaders
use strict;
use warnings;
use Getopt::Long;
use My::ChangingInvaders::Config;

# process command line arguments
my $files; # list of files
GetOptions(
    'files=s' => \$files,
);

# collect files
my $config = My::ChangingInvaders::Config->new( '-file' => $files );
my @list;
for my $sample ( $config->samples ) {
    for my $run ( $config->runs_for_sample($sample) ) {
        push @list, $config->files_for_run( run => $run, sample => $sample, type => 'raw' );
    }
}

for ( my $i = 0; $i < $#list - 1; $i += 2 ) {

    # files are listed as read pairs, R1 and R2
    my ( $in1,  $in2  ) = @list[$i, $i+1];
    my ( $out1, $out2 ) = ( $in1, $in2 );

    # make outfile names
    $out1 =~ s/fastq/fastp.fastq/;
    $out2 =~ s/fastq/fastp.fastq/;

    # make file stem
    my $stem = $in1;
    $stem =~ s/_R1_.*//;

    # make adaptor
    my $adaptor;
    if ( $stem =~ /_([AGCT]+)_L00/ ) {
        $adaptor = $1;
    }
    else {
        die $stem
    }

    system( "fastp -i $in1 -I $in2 -o $out1 -O $out2 -j ${stem}.json -h ${stem}.html -a $adaptor --verbose --dont_overwrite 2> ${stem}.log" );
}
