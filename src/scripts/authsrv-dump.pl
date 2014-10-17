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
use Getopt::Long;
use JSON;
use strict;

my $json;
my $help;
my $res = GetOptions(
    "json+" => \$json,
    "help+" => \$help,
);

if ( !$res || $help ) {
    print "Usage: $0 [--help] [--json]\n";
    exit(0);
}

#
# Retrieve listing of authsrv stashes, and output each one
#
my @entries = ();

open( CMDIN, "authsrv-list|" );
while ( chomp( my $line = <CMDIN> ) ) {
    my ( $owner, $user, $instance, $tstamp ) = split( /\//, $line );

    if ( $^O !~ /Win/ ) {
        unless ( open( FETCH, "-|" ) ) {
            exec( "authsrv-decrypt-raw", $owner, $user, $instance );
            exit(0);
        }
    }
    else {
        open( FETCH, "authsrv-decrypt-raw $owner $user $instance|" );
    }
	$pw = join("", <FETCH>);
    close(FETCH);

    my $encpw = encode_base64( $pw, "" );
    push(
        @entries,
        {   owner     => $owner,
            user      => $user,
            instance  => $instance,
            timestamp => $tstamp,
            password  => $encpw,
        }
    );

}
close(CMDIN);

if ( !$json ) {
    print "<authsrv>\n";

    foreach my $entry (@entries) {
        print "  <entry>\n";
        print "    <owner>",     $entry->{owner},     "</owner>\n";
        print "    <user>",      $entry->{user},      "</user>\n";
        print "    <instance>",  $entry->{instance},  "</instance>\n";
        print "    <timestamp>", $entry->{timestamp}, "</timestamp>\n";
        print "    <password>",  $entry->{password},  "</password>\n";
        print "  </entry>\n";
    }
    print "</authsrv>\n";
}
elsif ($json) {
    my $j = new JSON;

    $j->canonical(1);
    print $j->pretty->encode( \@entries ), "\n";
}

exit(0);
