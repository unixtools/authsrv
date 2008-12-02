#!/usr/bin/perl -t

# Begin-Doc
# Name: authsrv-load.pl
# Description: merge or replace authsrv stashes with data loaded from xml export file
# End-Doc

#
# This is explicitly disabled here - we're running a system level tool
# setuid as a user, otherwise running directly as that user in normal
# cases.
#
no warnings qw(taint);

use MIME::Base64;
use XML::Simple;
use Data::Dumper;
use strict;

$| = 1;

# Check if we are operating in merge mode
my $mode = "help";

if ( $ARGV[0] eq "--merge" ) {
    $mode = "merge";
    shift(@ARGV);
}

if ( $ARGV[0] eq "--load" ) {
    $mode = "load";
    shift(@ARGV);
}

if ( $ARGV[0] eq "-h" || $ARGV[0] eq "--help" ) {
    $mode = "help";
    shift(@ARGV);
}

if ( $mode eq "help" ) {
    print "Usage: $0 [--load|--merge] xmlfile\n";
    print
      "\this tool will bulk-load authsrv stashes from an XML file generated\n";
    print "\tby the authsrv-dump command.\n";
    exit;
}

#
# Retrieve listing of authsrv stashes, and note which ones are present
#
my %HAVE_ENTRY = ();
if ( $mode eq "load" ) {
    open( CMDIN, "authsrv-list|" );
    while ( chomp( my $line = <CMDIN> ) ) {
        my ( $owner, $user, $instance, $tstamp ) = split( /\//, $line );
        $HAVE_ENTRY{$owner}->{$user}->{$instance} = 1;
    }
    close(CMDIN);
}

#
# Now load any of the new entries
#
my $xmldata = join( "", <> );
my $xmlobj  = new XML::Simple;
my $data    = $xmlobj->XMLin( $xmldata, ForceArray => ['entry'] );

if ( ref( $data->{entry} ) ne "ARRAY" ) {
    die "Unable to parse input XML.\n";
}

my $cnt = 0;
foreach my $entry ( @{ $data->{entry} } ) {
    next if ( ref($entry) ne "HASH" );

    my $owner    = $entry->{owner}                     || next;
    my $user     = $entry->{user}                      || next;
    my $instance = $entry->{instance}                  || next;
    my $password = decode_base64( $entry->{password} ) || next;

    if ( $^O !~ /Win/ ) {
        unless ( open( STASH, "|-" ) ) {
            exec( "authsrv-encrypt", $owner, $user, $instance );
            exit(0);
        }
    }
    else {
        open( STASH, "|authsrv-encrypt $owner $user $instance" );
    }
    print STASH $password, "\n";
    close(STASH);

    $cnt++;
    delete $HAVE_ENTRY{$owner}->{$user}->{$instance};
    print "Processed entry #$cnt.\n";
}

foreach my $owner ( sort( keys(%HAVE_ENTRY) ) ) {
    foreach my $user ( sort( keys( %{ $HAVE_ENTRY{$owner} } ) ) ) {
        foreach
          my $instance ( sort( keys( %{ $HAVE_ENTRY{$owner}->{$user} } ) ) )
        {
            print "Purge old entry $owner/$user/$instance.\n";
            system( "authsrv-delete", $owner, $user, $instance );
        }
    }
}

exit(0);
