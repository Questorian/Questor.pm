#-------------------------------------------------------------------------
#
#                            P E R L    M O D U L E
#
#-------------------------------------------------------------------------
#
# QSCDE.pm
#
#-------------------------------------------------------------------------
# www.QuestorSystems.com              -:-     developer@QuestorSystems.com
#-------------------------------------------------------------------------
#
# QSCDE.pm: QSCDE - Questor Systems Common Desktop Environment
#
# Project:
# Author:	Farley Balasuriya (developer@QuestorSystems.com)
# Created:	2010-04-21T11:38:58
# History:
#       v0.3 - 2011-11-13 - Added support for imagtes in Twiki & PROJECTs
#		v0.2 - 2011-04-03 - tiddlywiki & journal support added
#		v0.1 - 2010-04-21 - initial version created
#
#-------------------------------------------------------------------------
$svn_rev = '$Rev: 110 $';
$svn_id  = '$Id: tapp.pl 110 2005-04-25 02:40:51Z farley $';
$svn_LastChangedDate =
  '$LastChangedDate: 2005-04-25 04:40:51 +0200 (Mon, 25 Apr 2005) $';

#-------------------------------------------------------------------------
# (c)1997 - 2010, QuestorSystems.com, All rights reserved.
# Gempenstrasse 46, CH-4053, Basel, Switzerland
# telephone:+41 79 285 6482,  email:developer@QuestorSystems.com
#-------------------------------------------------------------------------

package Questor::QSCDE;

use Questor;
use Questor::QSCDE::QObject;
use Questor::QSCDE::EO;
use Questor::QSCDE::PACK;
use Questor::QSCDE::PERSONA;

# version
use version; our $VERSION = qv('0.0.3');

use Moose;
use Carp;

# the master QSCDE variable - the root ofthe system
my $env_root_path = 'Q_PATH_ROOT';
my $env_xbin_path = 'Q_DRV_XBIN';

#use Readonly;
#use DateTime;
#use Config::Tiny;
#use Config::Std;

has 'root_path' => (
    is  => 'rw',
    isa => 'Str',

);

has 'name' => (
    is  => 'ro',
    isa => 'Str',
);

has 'xbin_path' => (
    is  => 'rw',
    isa => 'Str',
);

sub BUILD {
    my $self = shift;

    # if not passed to function - get from the environment

    if ( !$self->root_path ) {

        if ( $ENV{$env_root_path} ) {

            $self->root_path( $ENV{$env_root_path} );

        }
        else {
            die "unable to read $env_root_path - Is environment variable set?";
        }

    }

    # XBIN path - most important
    if ( $ENV{$env_xbin_path} ) {

        $self->xbin_path( $ENV{$env_xbin_path} );

    }
    else {
        die "unable to read $env_xbin_path - Is environment variable set?";
    }

    # return the root path
    $self->root_path;

}

sub root {
    my $self = shift;

    $self->root_path;
}

sub Q_PATH_ROOT {
    my $self = shift;

    # an alias for the 'root' function
    $self->root;
}

sub xbin {
    my $self = shift;

    $self->xbin_path;
}

sub Q_DRV_XBIN {
    my $self = shift;

    # alias for 'xbin' method
    $self->xbin;
}

sub enum_EO {
    my $self = shift;

    my @eos;

    my $eo_dir = $self->root_path . '\\EO';

    # lets find all the EO's in the $root directory
    foreach my $path_found ( glob( $eo_dir . '\\*' ) ) {

        # test if this is a directory
        if ( -d $path_found ) {

        # now get the last directory component of this path string using a regex
            $path_found =~ m/.\\(\w*)$/g;

            # save the EO and upper-case it too
            my $eo =
              Questor::QSCDE::EO->new( name => "\U$1", path => $path_found );

            # save the object to the return array
            push( @eos, $eo );

        }

    }

    @eos;

}

sub get_EO {
    my $self = shift;
    my $id   = uc(shift);

    my $qs = Questor::QSCDE->new();

    foreach my $e ( $qs->enum_EO ) {

        if ( $e->name eq $id ) {
            return $e

        }
    }

}

sub enum_PACK {
    my $self = shift;

    my @packs;

    my $pack_dir = $self->root_path . '\\PACK';

    # lets find all the EO's in the $root directory
    foreach my $path_found ( glob( $pack_dir . '\\PACK-*' ) ) {

        # test if this is a directory
        if ( -d $path_found ) {

        # now get the last directory component of this path string using a regex
            $path_found =~ m/.\\([-\w]*)$/g;

            # save the EO and upper-case it too
            my $eo =
              Questor::QSCDE::PACK->new( name => "\U$1", path => $path_found );

            # save the object to the return array
            push( @packs, $eo );

        }

    }

    @packs;

}

sub enum_PERSONA {
    my $self = shift;

    my @personas;

    my $persona_dir = $self->root_path . '\\PERSONA';

    # lets find all the EO's in the $root directory
    foreach my $path_found ( glob( $persona_dir . '\\*' ) ) {

        # test if this is a directory
        if ( -d $path_found ) {

        # now get the last directory component of this path string using a regex
            $path_found =~ m/.\\(\w*)$/g;

            # save the EO and upper-case it too
            my $p = Questor::QSCDE::PERSONA->new(
                name => "\U$1",
                path => $path_found
            );

            # save the object to the return array
            push( @personas, $p );

        }

    }

    @personas;

}

sub new_PACK {
    my $self = shift;
    my $name = shift;

    print "going to make PACK-$name\n";

    my $p = Questor::QSCDE::PACK->new(
        name => $name,
        path => $self->root_path . '\\PACK\\PACK-' . uc($name),
    );

    #create new PACK directory
    mkdir( $p->path ) ;
    die "$0: unable to create PACK directory!\n" if ! -d $p->path;

    #return the PACK object
    $p

}

# standard QSCDE directories - the root of the tree
my @qscde_dirs = qw/
  _td
  _td\cache
  _td\cache\AUDIO
  _td\cache\DOCS
  _td\cache\MISC
  _td\cache\PHOTOS
  _td\cache\VIDEO
  _td\inbox
  _td\inbox\AUDIO
  _td\inbox\DOCS
  _td\inbox\MISC
  _td\inbox\PHOTOS
  _td\inbox\VIDEO
  _td\logs
  cfg
  EO
  PACK
  /;

sub deploy {
    my $self = shift;

    print "deploy QSCDE to directory: ", $self->root_path, "\n";

    mkdir( $self->root_path ) unless -d $self->root_path;

    # now create all the directories we need
    # special case - QUESTOR can carry PERSONAs
    push( @qscde_dirs, 'PERSONA' ) if $self->name eq 'QUESTOR';
    create_directory_tree( $self->root_path, @qscde_dirs );

    # create a EO object

    my $eo = Questor::QSCDE::EO->new(
        name => uc( $self->name ),
        path => $self->root_path . '\\EO\\' . $self->name,
    );

    $eo->deploy;

    # PERSONA - make this EO the active PERSONA

    # ENVIRONMENT variable - how to set that? and WHERE?
    # $persona->make_active, $persona->activate, $persona->enable?

    # return true
    1;
}

#
# - Internal routines - for this module only below
#

#
# - End of Internal routines - for this module only
#

# Perl modules must exit with a value of 1
1;

__END__

=head1 Name

Questor::QSCDE.pm - Questor Systems Common Desktop Environment

=head1 VERSION

Questor::QSCDE beta version 0.0.2 - released April 2011

=head1 SYNOPSIS

    use Questor::QSCDE;

    # get a new Questor QSCDE object
    my $qs = Questor::QSCDE->new();


    print "Base path (alias root function): ", $q->root,        "\n";
    print "Base path: ",                       $q->Q_PATH_ROOT, "\n";

    print "XBIN path: ",                   $q->xbin,       "\n";
    print "XBIN path (\$q->Q_DRV_XBIN): ", $q->Q_DRV_XBIN, "\n";


    # start backing-up
    foreach my $e ( $qs->enum_EO() ) {

      printf( "%-12s - %s\n", $e->name, $e->path_twiki );

      # print Tiddly Wiki
      print "found tiddlywiki: ", $e->path_twiki";

      # backup PST files including previous years
      bkupfile($e->path_pst, 'c:\\temp\\backups');


      # backup journals - including previous two years
      bkupfile( $e->path_journal,     $basedir . '\\journals' );
      bkupfile( $e->path_journal(-1), $basedir . '\\journals' );
      bkupfile( $e->path_journal(-2), $basedir . '\\journals' );

}


    print "now we are going to test the PACK stuff ...\n";
    foreach my $pack ($q->enum_PACK()) {
      print "PACK -> ", $pack->name, " - path: ", $pack->path, "\n";
        }


    print "we are now going to check out all the PERSONAs ...\n";
    foreach my $persona ($q->enum_PERSONA()) {

      print "PSERSONA -> ", $persona->name, " - path: ", 
        $persona->path, "\n";

        }


=head1 DESCRIPTION

Perl module to simplify the management of the Questor QSCDE environment. 

The object model is Moose based and allows for the creation, mangement, 
backup, and deletion of objects such as: PERSONA, PACK, ALIAS, and EOs.

This module is considered beta and the API is likely to change as 
development occurs

=head1 DIAGNOTICS


=head1 CONFIGURATION AND ENVIRONMENT

You will need to ensure that at the very minimum the DOS CMD environment
variable:

    Q_PATH_ROOT

Is set. you could then also set the variable:

    Q_DRV_XBIN

But this will eventually be moved to the QSCDE ini configuration file
found in the Q_PATH_ROOT directory.

=head1 DEPENDENCIES

DateTime, Moose, and a number of other modules

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 REVISION HISTORY
    2012-01-27 - v0.3 - qscde.pl tool additions - EO, & PERSONA, etc
    2011-04-01 - v0.2 - added twiki and journal support
    2010-04-21 - v0.1 - initial version created

    see CHANGES for full revision changes
    
=head1 SEE ALSO

Questor - Questor Systems main module

=head1 AUTHOR

    Farley Balasuriya   (developer@QuestorSystems.com)

=head1 LICENCE AND COPYRIGHT

Copyright (c) 1996-2011 Farley J. Balasuriya.  All rights reserved.  This
program is free software; you can redistribute it and/or modify it under the 
same terms as Perl itself.


The full text of the license can be found in the LICENSE file included
with this module.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR 
THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN 
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES 
PROVIDE THE SOFTWARE " AS IS " WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
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
