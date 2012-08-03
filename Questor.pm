#-------------------------------------------------------------------------
#
#                            P E R L    M O D U L E
#
#-------------------------------------------------------------------------
#
# Questor.pm
#
#-------------------------------------------------------------------------
# www.QuestorSystems.com              -:-     developer@QuestorSystems.com
#-------------------------------------------------------------------------
#
# Questor.pm: Questor in-house custom routines and utillity functions
#
# Project:
# Author:	Farley Balasuriya (developer@QuestorSystems.com)
# Created:	2008-11-29T20:12:32
# History:
#		v0.4 - 2011-04-18 - added generate_password
#		v0.1 - 2008-11-29 - initial version created
#
#-------------------------------------------------------------------------
$svn_rev = '$Rev: 110 $';
$svn_id  = '$Id: tapp.pl 110 2005-04-25 02:40:51Z farley $';
$svn_LastChangedDate =
  '$LastChangedDate: 2005-04-25 04:40:51 +0200 (Mon, 25 Apr 2005) $';

#-------------------------------------------------------------------------
# (c)1997 - 2008, QuestorSystems.com, All rights reserved.
# Gempenstrasse 46, CH-4053, Basel, Switzerland
# telephone:+41 79 285 6482,  email:developer@QuestorSystems.com
#-------------------------------------------------------------------------

package Questor;

use version; our $VERSION = qv('0.0.4');

# module export
require Exporter;
our @ISA = qw(Exporter);
@EXPORT =
  qw( date time_hms timestamp week_number month2num generate_password create_directory_tree);

use strict;
use warnings;
use Carp;
use DateTime;

#use Readonly;
#use Config::Std;
#use Config::Tiny;

my $time_zone = 'Europe/Zurich';

# ---- windows routines - will eventually move  - Questor::Win32
# --


### INTERFACE SUB ###
# Usage     : $month_number = month2num ($monthname)
# Purpose   : converts a names month in English to it's relevant number
# Returns   : integer between 1 and 12, or 0 if it failed to find anything
# Parameters: name of month - from 3 digits upwards (Jan, Feb, March, april, MAY, JUne)
# Comments  : ignores case and only matches first three characters
# See Also  : n/a
sub month2num {
    my ($month_name) = @_;

    # convert the SCCM log string month to a number usable by DateTime
    # see: http://www.perlmonks.org/?node_id=95456

    my %mon2num = qw(
      jan 1  feb 2  mar 3  apr 4  may 5  jun 6
      jul 7  aug 8  sep 9  oct 10 nov 11 dec 12
    );

    my $num = $mon2num{ lc substr( $month_name, 0, 3 ) };

    return $num;

}
### INTERFACE SUB ###
# Usage     : ???
# Purpose   : ???
# Returns   : ???
# Parameters: ???
# Comments  : none
# See Also  : n/a
sub timestamp {
    my ($v) = @_;

    my $datetime = _get_datetime_now();

    return $datetime->iso8601;

}
### INTERFACE SUB ###
# Usage     : ???
# Purpose   : ???
# Returns   : ???
# Parameters: ???
# Comments  : none
# See Also  : n/a
sub date {
    my ($v) = @_;

    my $datetime = _get_datetime_now();

    return $datetime->ymd;
}

### INTERFACE SUB/INTERNAL UTILITY ###
# Usage     : ???
# Purpose   : ???
# Returns   : ???
# Parameters: ???
# Comments  : none
# See Also  : n/a
sub time_hms {
    my ($v) = @_;

    my $datetime = _get_datetime_now();

    return $datetime->hms;
}


sub generate_password {
    my $length = shift || 14;

    my @chars = ( "A" .. "Z", "a" .. "z", 0 .. 9, qw(! @ $ ^ - + _ [ ] ) );

    my $password = join( "", @chars[ map { rand @chars } ( 1 .. $length ) ] );

}



### INTERFACE SUB/INTERNAL UTILITY ###
# Usage     : ???
# Purpose   : ???
# Returns   : ???
# Parameters: ???
# Comments  : none
# See Also  : n/a
sub week_number {
    my ($v) = @_;

    my $datetime = _get_datetime_now();

    return $datetime->week_number;
}


sub create_directory_tree
{
my $root = shift;
my @dirs = @_;



    # make PERSONA root
    mkdir($root);

    foreach my $dir  (@dirs) {

        my $dir  = $root . '\\' . $dir ;
        print "creating: $dir \n";
        mkdir($dir ) unless -d $dir ;
                                                                          
    }

}


#
# - Internal routines - for this module only below
#

sub _get_datetime_now {
    my ($v) = @_;

    return DateTime->now( time_zone => $time_zone );

}

#
# - End of Internal routines - for this module only
#


# Perl modules must exit with a value of 1
1;

__END__

=head1 Name

Questor.pm - <one line description of applications purpose>

=head1 VERSION

This documentation referes to  version 0.0.4

=head1 USAGE

    # brief working invocation example(s) here showing the most common usage

    # most readers will not read past here so make it good

=head1 REQUIRED ARGUMENTS

A complete list of every argument that must appear on the command line

=head1 OPTIONS

=head1 DESCRIPTION


=head2 Passwords

Passwords can be created using the generate_password() function which is
useful for this constantly recurring task. Default password length is 14 
characters which is sufficient for most purposes, however for secure websites
or blogs, and databases etc consider using a minimum of 20 characters or more:


  # generate a password of length $length
  my $password = generate_password($length);

  # generate a default 14 character password
  my $password = generate_password();


=head1 DIAGNOTICS


=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 REVISION HISTORY

	2008-11-29 - v0.1 - initial version created
    
    see CHANGES for complete change history
    
=head1 SEE ALSO

=head1 AUTHOR

    Farley Balasuriya   (developer@QuestorSystems.com)

=head1 LICENCE AND COPYRIGHT

Copyright (c) 1996 - 2011 Farley J. Balasuriya.  All rights reserved.  This
program is free software; you can redistribute it and/or modify it under the 
same terms as Perl itself.


The full text of the license can be found in the LICENSE file included
with this module.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR 
THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN 
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES 
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS 
TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH YOU. SHOULD THE 
SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, 
REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL 
ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE 
THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE TO YOU FOR DAMAGES, 
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING 
OUT OF THE USE OR INABILITY TO USE THE SOFTWARE (INCLUDING BUT NOT LIMITED TO 
LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR 
THIRD PARTIES OR A FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER 
SOFTWARE), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE 
POSSIBILITY OF SUCH DAMAGES.
