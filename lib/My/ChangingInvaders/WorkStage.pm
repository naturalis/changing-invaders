package My::ChangingInvaders::WorkStage;
use strict;
use warnings;
use File::Spec;
use File::Copy;
use Digest::MD5;

sub new {
    my ( $package, $stage ) = @_;
    die "Not a folder: $stage" unless -d $stage;
    bless {
        files => {},
        stage => $stage,
    }, $package;
}

sub workdir {
    my ( $self, $dir ) = @_;
    if ( $dir ) {
        die "Not a folder: $dir" unless -d $dir;
        $self->{stage} = $dir;
    }
    return $self->{stage};
}

sub stage {
    my ( $self, $file ) = @_;
    my ( $volume, $directories, $base ) = File::Spec->splitpath( $file );
    copy( $file, $self->workdir ) if -e $file;
    my $staged = File::Spec->catfile( $self->workdir, $base );
    $self->{files}->{$file} = $staged;
    return $staged;
}

sub _unstage {
    my ( $self, $output, $input ) = @_;
    if ($self->md5($input) eq $self->md5($output)) {
        unlink $output
    }
    else {
        warn "staged copy $output differs from $input, won't unstage";
    }
}

sub unstage_all {
    my $self = shift;
    for my $input ( keys %{ $self->{files} } ) {
        my $output = $self->{files}->{$input};

        # there is staged output as a single file
        if ( -e $output ) {

            # there is input, i.e. a single copy
            if ( -e $input ) {
                $self->_unstage($output => $input);
            }

            # there is output but not input, copy back
            else {
                copy( $output, $input );
                $self->_unstage($output => $input);
            }
        }
        else {
            my @outfiles = glob("${output}*");
            for my $out ( @outfiles ) {

            }
        }
    }
}

sub md5 {
    my ( $self, $file ) = @_;
    open ( my $fh, '<', $file ) or die "Can't open '$file': $!";
    binmode ($fh);
    return Digest::MD5->new->addfile($fh)->hexdigest;
}

1;

