#!/usr/bin/perl -t

# Begin-Doc
# Name: authsrv-dump.pl
# Description: dump all accessible authsrv-data in xml format
# End-Doc

#
# This is explicitly disabled here - we're running a system level tool
# setuid as a user, otherwise running directly as that user in normal
# cases.
#
$| = 1;
no warnings qw(taint);

use MIME::Base64;
use strict;

print "<authsrv>\n";

#
# Retrieve listing of authsrv stashes, and output each one
#
open( CMDIN, "authsrv-list|" );
while ( chomp( my $line = <CMDIN> ) ) {
    my ( $owner, $user, $instance, $tstamp ) = split( /\//, $line );

    if ( $^O !~ /Win/ ) {
        unless ( open( FETCH, "-|" ) ) {
            exec( "authsrv-decrypt", $owner, $user, $instance );
            exit(0);
        }
    }
    else {
        open( FETCH, "authsrv-decrypt $owner $user $instance|" );
    }
    chomp( my $pw = <FETCH> );
    close(FETCH);

    my $encpw = encode_base64( $pw, "" );

    print "  <entry>\n";
    print "    <owner>$owner</owner>\n";
    print "    <user>$user</user>\n";
    print "    <instance>$instance</instance>\n";
    print "    <timestamp>$tstamp</timestamp>\n";
    print "    <password>$encpw</password>\n";
    print "  </entry>\n";
}
close(CMDIN);

print "</authsrv>\n";

exit(0);
