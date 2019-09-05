package My::ChangingInvaders::Config;
use strict;
use warnings;
use YAML::Syck;

sub new {
    my ( $package, %args ) = @_;
    my $self;
    if ( my $file = $args{'-file'} ) {
        $self = LoadFile($file);
    }
    elsif ( my $data = $args{'-data'} ) {
        $self = Load($data);
    }
    else {
        $self = {};
    }
    return bless $self, $package;
}

sub references {
    my $self = shift;
    return keys %{ $self->{'reference'} };
}

sub file_for_reference {
    my ( $self, $ref ) = @_;
    return $self->{'reference'}->{$ref};
}

sub samples {
    my $self = shift;
    return keys %{ $self->{'sample'} };
}

sub runs_for_sample {
    my ( $self, $sample ) = @_;
    return keys %{ $self->{'sample'}->{$sample}->{'run'} };
}

sub files_for_run {
    my ( $self, %args ) = @_;
    my ( $run, $sample, $type, $list ) = @args{qw[run sample type list]};
    if ( $list ) {
        $self->{'sample'}->{$sample}->{run}->{$run}->{file}->{$type} = $list;
    }
    return @{ $self->{'sample'}->{$sample}->{run}->{$run}->{file}->{$type} };
}

sub files_for_sample {
    my ( $self, %args ) = @_;
    my ( $sample, $type, $list ) = @args{qw[sample type list]};
    if ( $list ) {
        $self->{'sample'}->{$sample}->{file}->{$type} = $list;
    }
    return @{ $self->{'sample'}->{$sample}->{file}->{$type} };
}

sub to_string { Dump(shift) }

1;