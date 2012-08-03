#
# - EO - QSCDE Entity Object
#

package Questor::QSCDE::EO;

use Moose;

use DateTime;
use Time::Piece;

use Questor;

extends 'Questor::QSCDE::QObject';

sub path_pst {
    my $self   = shift;
    my $offset = shift;

    $self->path
      . '\\DATA\\PST\\'
      . $self->name . '-'
      . _get_year($offset) . '.pst';

}

sub path_ini {
    my $self = shift;

    $self->path . '\\CONFIG\\eo.ini';
}

sub path_twiki {
    my $self = shift;

    $self->path
      . '\\DATA\\DOCS\\documentation\\wikis\\'
      . lc( $self->name ) . '.html';

}

sub path_twiki_images {
    my $self = shift;

    $self->path . '\\DATA\\DOCS\\documentation\\wikis\\images'

}

sub path_journal {
    my $self   = shift;
    my $offset = shift;

    $self->path
      . '\\DATA\\DOCS\\documentation\\journals\\'
      . lc( $self->name )
      . ( defined($offset) ? '-' . _get_year($offset) : '' ) . '.txt';
}

my @eo_dirs = qw/

  admin
  admin\_general
  bin
  bkup
  bkup\PST
  config
  data
  data\DOCS
  data\DOCS\documentation
  data\DOCS\documentation\_templates
  data\DOCS\documentation\wiki
  data\PST

  /;

sub deploy {

    my $self = shift;

    my $root = $self->path;

    print "deploy EO to directory: $root\n";

    # add the admin\current-year subdirectory
    my $t = localtime;
    push( @eo_dirs, 'admin\\' . $t->year );

    create_directory_tree( $root, @eo_dirs );

    # create the EO INI file
    $self->_create_ini;

}

# -----------------------------------
# Internal calls - to subroutine only
# -----------------------------------

sub _create_ini {

    my $self = shift;

    my $t = localtime;

    open( my $INI, '>', $self->path_ini )
      or die "uable to create ini file: ", $self->path_ini, "\n";

    # write the EO INI file
    print $INI ";QSCDE INI file for EO:", $self->name, " (", $t->ymd, ")\n\n";

    print $INI "EO=",      $self->name, "\n";
    print $INI "created=", $t->ymd,     "\n";

    close($INI);

}

sub _get_year {
    my $offset = shift;

    if ( !defined $offset ) {
        $offset = 0;
    }

    my $dt = DateTime->now();

    $dt->year + $offset;

}

1;
