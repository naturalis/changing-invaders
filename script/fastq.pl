#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

# process command line arguments
my $files;
my $data;
GetOptions(
    'files=s' => \$files,
    'data=s'  => \$data,
);

my @list;
open my $fh, '<', $files;
while(<$fh>) {
    chomp;
    push @list, $_ if -e $_;
}

for ( my $i = 0; $i < $#list - 1; $i += 2 ) {
    my ( $in1, $in2 ) = @list[$i, $i+1];
    system( "cp $in1 $in2 $data" );
    $in1 =~ s/.*\//$data/;
    $in2 =~ s/.*\//$data/;
    my ( $out1, $out2 ) = ( $in1, $in2 );
    my $log = $in1;
    $log =~ s/_R1_.*/.log/;
    $out1 =~ s/fastq/fastp.fastq/;
    $out2 =~ s/fastq/fastp.fastq/;
    system( "fastp -i $in1 -I $in2 -o $out1 -O $out2 2> $log" );
}