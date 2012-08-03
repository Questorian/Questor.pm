#-------------------------------------------------------------------------
#
#                            P E R L    M O D U L E 
#
#-------------------------------------------------------------------------
#
# Questor::Win32.pm
#
#-------------------------------------------------------------------------
# www.QuestorSystems.com              -:-     developer@QuestorSystems.com
#-------------------------------------------------------------------------
#
# Questor::Win32.pm: functions to handle Win32 
#
# Project:	
# Author:	Farley Balasuriya (developer@QuestorSystems.com)
# Created:	2011-04-01T19:31:29
# History:
#		v0.2 - 
#		v0.1 - 2011-04-01 - initial version created
#            
#-------------------------------------------------------------------------
$svn_rev='$Rev: 110 $';
$svn_id='$Id: tapp.pl 110 2005-04-25 02:40:51Z farley $';
$svn_LastChangedDate='$LastChangedDate: 2005-04-25 04:40:51 +0200 (Mon, 25 Apr 2005) $';
#-------------------------------------------------------------------------
# (c)1997 - 2011, QuestorSystems.com, All rights reserved.
# Gempenstrasse 46, CH-4053, Basel, Switzerland
# telephone:+41 79 285 6482,  email:developer@QuestorSystems.com
#-------------------------------------------------------------------------

package Questor::Win32;

# version
use version; our $VERSION = qv('0.0.1');


# exports
use base qw( Exporter);

our @EXPORT    = qw / olmail oltask Win32MsgBox/ ;
our @EXPORT_OK = qw / / ;

use strict;
use warnings;
use Carp;

use Win32;
use Win32::OLE;
use Win32::OLE::Const 'Microsoft Outlook';


#use Readonly;
#use DateTime;
#use Config::Tiny;
#use Config::Std;

#
# TBD
#
# ol functions for outlook - need to check that outlook is actually runing
#

### INTERFACE SUB/INTERNAL UTILITY ###
# Usage     : ???
# Purpose   : ???
# Returns   : ???
# Parameters: ???
# Comments  : flags
#
#        0 = OK
#        1 = OK and Cancel
#        2 = Abort, Retry, and Ignore
#        3 = Yes, No and Cancel
#        4 = Yes and No
#        5 = Retry and Cancel
#
#        MB_ICONSTOP          "X" in a red circle
#        MB_ICONQUESTION      question mark in a bubble
#        MB_ICONEXCLAMATION   exclamation mark in a yellow triangle
#        MB_ICONINFORMATION   "i" in a bubble
#
# See Also  : n/a
sub Win32MsgBox {
    my ( $message, $title ) = @_;

    # if we have not got a title, use the default - QSCDE
    if ( !defined($title) ) {
        $title = "QSCDE";
    }

    # set the type of box we want - see flags above
    my $flags = MB_ICONEXCLAMATION;

    # call Win32 and return the value to caller
    return Win32::MsgBox( $message, $flags, $title );

}

### INTERFACE SUB/INTERNAL UTILITY ###
# Usage     : ???
# Purpose   : ???
# Returns   : ???
# Parameters: ???
# Comments  : none
# See Also  : n/a
sub oltask {
    my ($args_ref) = @_;

    # check outlook is running - we need to check this first!

    # create Outlook object
    my $outlook = new Win32::OLE('Outlook.Application');

    # create a task
    my $taskitem = $outlook->CreateItem(olTaskItem);
    die "Can't create TaskItem, $!, $^E" unless ($taskitem);

    # set the subject
    if ( $$args_ref{subject} ) {
        $taskitem->{Subject} = $$args_ref{subject};
    }

    # set the body
    if ( $$args_ref{body} ) {
        $taskitem->{Body} = $$args_ref{body};
    }

    # set the due date - specify the number of days offset
    if ( my $days = $$args_ref{duedate} ) {

        # check that this is a reasonable number of days offset
        if ( $days > 0 && $days < 1200 ) {

            my $dt = _get_datetime_now();
            $dt->add( days => $days );

            # set date due on task
            $taskitem->{DueDate} = $dt->ymd;
        }

    }

    # set the categories - comma seperated  list
    if ( $$args_ref{categories} ) {
        $taskitem->{Categories} = $$args_ref{categories};
    }

    # Display it or save it !
    if ( $$args_ref{display} ) {
        $taskitem->Display();

    }
    else {
        $taskitem->Save();
    }

    # return some kind of meaningful value

}

### INTERFACE SUB/INTERNAL UTILITY ###
# Usage     : ???
# Purpose   : ???
# Returns   : ???
# Parameters: ???
# Comments  : none
# See Also  : n/a
sub olmail {
    my ($args_ref) = @_;

    # create Outlook onject
    my $outlook  = new Win32::OLE('Outlook.Application');
    my $mailitem = $outlook->CreateItem(olMailItem);
    die "Can't create mailitem, $!, $^E" unless ($mailitem);

    # To - this is not optional
    if ( $$args_ref{'to'} ) {
        $mailitem->{To} = $$args_ref{'to'};
    }
    else {
        die "no email recipient specified - you need to specify 'to'";
    }

    # Subject - if specified
    if ( $$args_ref{'subject'} ) {
        $mailitem->{Subject} = $$args_ref{'subject'};
    }

    # Body - if specified
    if ( $$args_ref{'body'} ) {
        my $suffix = "";

        # check if a 'timestamp' has been requested for email
        if ( $$args_ref{timestamp} ) {
            $suffix = sprintf( "\nISO-8601 Timestamp: %s\n", timestamp() );
        }

        $mailitem->{Body} = $$args_ref{'body'} . $suffix;
    }

    # Body_file - if specified
    # we want text out of file - a kind of simple text template
    if ( $$args_ref{'body_file'} ) {
        my $suffix = "";

        # check if a 'timestamp' has been requested for email
        if ( $$args_ref{timestamp} ) {
            $suffix = sprintf( "\nISO-8601 Timestamp: %s\n", timestamp() );
        }

        # slurp in the file
        open( BODY, $$args_ref{'body_file'} );
        my $body_str;
        while (<BODY>) {
            $body_str .= $_;
        }
        close(BODY);

        $mailitem->{Body} = $body_str . $suffix;
    }

    # CC - if specified
    if ( $$args_ref{'cc'} ) {
        $mailitem->{CC} = $$args_ref{'cc'};
    }

    # BCC - if specified
    if ( $$args_ref{'bcc'} ) {
        $mailitem->{BCC} = $$args_ref{'bcc'};
    }

    # attachments if spefied
    if ( my $array_ref = @$args_ref{'attachments'} ) {

        foreach my $item (@$array_ref) {

            #  Verify the existence of the file attachment
            next unless ( -e $item );

            #  Go ahead and attach this file
            #  See - http://www.outlookcode.com/codedetail.aspx?id=481
            my $Attachments = $mailitem->Attachments();
            $Attachments->Add($item);

        }
    }

    # send the bloody thing - Outlook must be open and running
    if ( $$args_ref{send} ) {
        return $mailitem->Send();
    }
    else {

        # display it - if not being sent - you must explicity send it
        return $mailitem->Display();
    }

}





    # Perl modules must exit with a value of 1
    1;

__END__

=head1 Name

Win32.pm - <one line description of applications purpose>

=head1 VERSION

This documentation referes to  version 0.0.1

=head1 USAGE

    # brief working invocation example(s) here showing the most common usage

    # most readers will not read past here so make it good


=head1 DESCRIPTION

    full description of product, could include =head2, =head3, etc

=head1 DIAGNOTICS


=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 REVISION HISTORY

	2011-04-01 - v0.0.1 - initial version created

    See Changes for complete revision history
    
=head1 SEE ALSO

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