#
# - QObject - A base object used to derive other QSCDE classes
#

package Questor::QSCDE::QObject;

use Moose;

has 'name' => (
    is  => 'ro',
    isa => 'Str',
);

has 'path' => (
    is  => 'ro',
    isa => 'Str',
);




# return true
1;