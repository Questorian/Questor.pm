#
# - PACK - QSCDE PROJECT Object
#       Internet Projects that apply to Ipanema
#

package Questor::QSCDE::PROJECT;

use Moose;

#This class extends the single EO - Ipanema
# and is for all Internet Marketing projects
extends 'Questor::QSCDE::EO';

# class extensions


sub path_twiki {
    my $self = shift;

    $self->path
      . '\\DATA\\projects\\' . lc($self->name) . '\\wiki\\'
      . lc( $self->name ) . '.html';

}



1;
