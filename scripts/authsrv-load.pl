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
    print "Usage: $0 [--load|--merge] file\n";
    print "\this tool will bulk-load authsrv stashes from an XML or JSON file generated\n";
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
my $indata  = join( "", <> );
my @entries = ();
my $cnt     = 0;

if ( $indata =~ /^<authsrv/o ) {
    eval "use XML::Simple";
    my $xmlobj = new XML::Simple;
    my $data = $xmlobj->XMLin( $indata, ForceArray => ['entry'] );

    if ( ref( $data->{entry} ) ne "ARRAY" ) {
        die "Unable to parse input XML.\n";
    }

    foreach my $entry ( @{ $data->{entry} } ) {
        next if ( ref($entry) ne "HASH" );

        my $owner    = $entry->{owner}                     || next;
        my $user     = $entry->{user}                      || next;
        my $instance = $entry->{instance}                  || next;
        my $password = decode_base64( $entry->{password} ) || next;
        push(
            @entries,
            {   owner    => $owner,
                user     => $user,
                instance => $instance,
                password => $password,
            }
        );
    }
}
elsif ( $indata =~ /^\s*\[/o ) {
    eval "use JSON";

    my $data;
    eval { $data = decode_json($indata); };
    if ( !$data ) {
        die "Unable to parse input JSON.\n";
    }

    foreach my $entry (@$data) {
        my $owner    = $entry->{owner}                     || next;
        my $user     = $entry->{user}                      || next;
        my $instance = $entry->{instance}                  || next;
        my $password = decode_base64( $entry->{password} ) || next;

        push(
            @entries,
            {   owner    => $owner,
                user     => $user,
                instance => $instance,
                password => $password,
            }
        );
    }
}

foreach my $entry (@entries) {
    my $owner    = $entry->{owner};
    my $user     = $entry->{user};
    my $instance = $entry->{instance};
    my $password = $entry->{password};

    my $enc;
    if ( $^O !~ /Win/ ) {
        unless ( open( $enc, "|-" ) ) {
            exec( "authsrv-raw-encrypt", $owner, $user, $instance );
            exit(0);
        }
    }
    else {
        open( $enc, "|-" ) || exec( "authsrv-raw-encrypt", $owner, $user, $instance );
    }
    print $enc $password;
    close($enc);

    $cnt++;
    delete $HAVE_ENTRY{$owner}->{$user}->{$instance};
    print "Processed entry #$cnt.\n";
}

# HAVE_ENTRY only populated if mode=load
foreach my $owner ( sort( keys(%HAVE_ENTRY) ) ) {
    foreach my $user ( sort( keys( %{ $HAVE_ENTRY{$owner} } ) ) ) {
        foreach my $instance ( sort( keys( %{ $HAVE_ENTRY{$owner}->{$user} } ) ) ) {
            print "Purge old entry $owner/$user/$instance.\n";
            system( "authsrv-delete", $owner, $user, $instance );
        }
    }
}

exit(0);
