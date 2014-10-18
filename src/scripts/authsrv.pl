#!/usr/bin/perl

# Begin-Doc
# Type: script
# Name: authsrv.pl
# Description: simple text based authsrv UI
# End-Doc

use strict;
$| = 1;

my $STASHCOUNT;
my %STASHED;

&get_list();
while (1) {
    print "\nAuthSrv: $STASHCOUNT stashed passwords\n";
    print "Action: (S)tash (D)elete (L)ist (P)rint (T)est System (Q)uit: ";
    chomp( my $line = <STDIN> );
    last if ( !defined($line) );
    $line = lc $line;

    if ( $line eq "s" || $line eq "stash" ) {
        &handle_stash();
    }
    elsif ( $line eq "d" || $line eq "delete" ) {
        &handle_delete();
    }
    elsif ( $line eq "l" || $line eq "list" ) {
        &handle_list();
    }
    elsif ( $line eq "p" || $line eq "print" ) {
        &handle_print();
    }
    elsif ( $line eq "t" || $line eq "test" ) {
        &handle_self_test();
    }
    elsif ( $line eq "q" || $line eq "quit" || $line eq "exit" ) {
        last;
    }
}
print "\n";

# Begin-Doc
# Name: get_list
# Type: function
# Description: retrieve current list of stashes into global hash
# End-Doc
sub get_list {
    open( CMDIN, "authsrv-list|" );
    $STASHCOUNT = 0;
    %STASHED    = ();
    while ( chomp( my $line = <CMDIN> ) ) {
        my ( $owner, $user, $instance, $tstamp ) = split( /\//, $line );
        $STASHCOUNT++;
        $STASHED{$owner}->{$user}->{$instance} = $tstamp;
    }
    close(CMDIN);
}

# Begin-Doc
# Name: handle_list
# Type: function
# Description: handler function for the 'L' list operation
# End-Doc
sub handle_list {
    my $last_owner;
    my $last_user;

    if ( $STASHCOUNT == 0 ) {
        print "\n";
        print "There are currently no passwords stashed that you have access to.\n";
        return;
    }

    print "\n";
    print "Currently Stashed Passwords ($STASHCOUNT):\n";
    print "--------------------------------------------------------------------\n";
    print "Owner    User     Instance           Modification Time\n";
    print "--------------------------------------------------------------------\n";
    my $last_ou;
    foreach my $owner ( sort( keys(%STASHED) ) ) {

        foreach my $user ( sort( keys( %{ $STASHED{$owner} } ) ) ) {
            foreach my $instance ( sort( keys( %{ $STASHED{$owner}->{$user} } ) ) ) {
                my $ou = $owner . "\0" . $user;
                if ( $ou ne $last_ou ) {
                    print "$owner\n";
                    print " \\------ $user\n";
                    $last_ou = $ou;
                }

                print "          \\------ $instance    ";
                print " " x ( 15 - length($instance) );
                print
                    scalar( localtime( $STASHED{$owner}->{$user}->{$instance} ) ),
                    "\n";
            }
        }
    }
    print "\n";
}

# Begin-Doc
# Name: handle_stash
# Type: function
# Description: handler function for the 'S' stash operation
# End-Doc
sub handle_stash {
    print "\n";

    print "Enter information for new or updated stash:\n";
    my $owner    = &prompt_owner()     || return;
    my $user     = &prompt("User")     || return;
    my $instance = &prompt("Instance") || return;
    my $pw       = &prompt_pw()        || return;

    print "\n";
    if ( $^O !~ /win/i ) {
        open( CMD, "|-" )
            || exec( "authsrv-encrypt", $owner, $user, $instance );
    }
    else {
        open( CMD, "|authsrv-encrypt $owner $user $instance" );
    }
    print CMD $pw, "\n";
    close(CMD);
    print "\n";

    &get_list();
}

# Begin-Doc
# Name: handle_delete
# Type: function
# Description: handler function for the 'D' delete operation
# End-Doc
sub handle_delete {
    my ( $owner, $user, $instance );

    print "\n";
    print "Enter information to delete a stash:\n";
    print "Enter * to delete all matching entries.\n";

    $owner = &prompt_owner() || return;
    if ( $owner ne "*" ) {
        $user = &prompt("User") || return;
    }
    else {
        $user = "*";
    }
    if ( $user ne "*" ) {
        $instance = &prompt("Instance") || return;
    }
    else {
        $instance = "*";
    }

    foreach my $fowner ( sort( keys(%STASHED) ) ) {
        next if ( $owner ne $fowner && $owner ne "*" );

        foreach my $fuser ( sort( keys( %{ $STASHED{$fowner} } ) ) ) {
            next if ( $user ne $fuser && $user ne "*" );

            foreach my $finstance ( sort( keys( %{ $STASHED{$fowner}->{$fuser} } ) ) ) {
                next if ( $instance ne $finstance && $instance ne "*" );

                print "Delete $fowner / $fuser / $finstance (Y/N)? ";
                my $yn;
                chomp( $yn = <STDIN> );
                if ( $yn =~ /^\s*y/io ) {
                    print "  deleting $fowner / $fuser / $finstance:\n";
                    system( "authsrv-delete", $fowner, $fuser, $finstance );
                    if ($?) {
                        print "\n";
                    }
                }
            }
        }
    }

    &get_list();
}

# Begin-Doc
# Name: handle_print
# Type: function
# Description: handler function for the 'P' print operation
# End-Doc
sub handle_print {
    my ( $owner, $user, $instance );

    print "\n";
    print "Enter information to print contents of a stash:\n";
    print "Enter * to print all matching entries.\n";

    $owner = &prompt_owner() || return;
    if ( $owner ne "*" ) {
        $user = &prompt("User") || return;
    }
    else {
        $user = "*";
    }
    if ( $user ne "*" ) {
        $instance = &prompt("Instance") || return;
    }
    else {
        $instance = "*";
    }

    print "\n";
    foreach my $fowner ( sort( keys(%STASHED) ) ) {
        next if ( $owner ne $fowner && $owner ne "*" );

        foreach my $fuser ( sort( keys( %{ $STASHED{$fowner} } ) ) ) {
            next if ( $user ne $fuser && $user ne "*" );

            foreach my $finstance ( sort( keys( %{ $STASHED{$fowner}->{$fuser} } ) ) ) {
                next if ( $instance ne $finstance && $instance ne "*" );

                print "$fowner / $fuser / $finstance:\n";
                system( "authsrv-decrypt", $fowner, $fuser, $finstance );
                print "\n";
            }
        }
    }

    &get_list();
}

# Begin-Doc
# Name: prompt_owner
# Description: prompt for the owner if root, otherwise just display
# Returns: $owner as string
# End-Doc
sub prompt_owner {
    my $owner;

    if ( $^O =~ /win/i ) {
        $owner = "common";
        print "Owner: $owner\n";
    }
    elsif ( $< == 0 ) {
        print "Owner: ";
        chomp( $owner = <STDIN> );
    }
    else {
        $owner = ( getpwuid($<) )[0];
        print "Owner: $owner\n";
    }
    return $owner;
}

# Begin-Doc
# Name: prompt
# Description: generic prompt
# Returns: value as string
# End-Doc
sub prompt {
    my $label = shift;
    print "$label: ";
    my $str;
    chomp( $str = <STDIN> );
    return $str;
}

# Begin-Doc
# Name: prompt_pw
# Description: prompt for pw with validation
# Returns: pw as string
# End-Doc
sub prompt_pw {
    my ( $pw, $pw2 );

    print "Password: ";
    if ( $^O !~ /win/i ) {
        system("stty -echo");
    }
    chomp( $pw = <STDIN> );
    print "\n";

    print "Verify: ";
    chomp( $pw2 = <STDIN> );
    print "\n";
    if ( $^O !~ /win/i ) {
        system("stty echo");
    }

    if ( $pw eq $pw2 ) {
        return $pw;
    }
    else {
        print "Passwords do not match!\n";
        return undef;
    }
}

# Begin-Doc
# Name: handle_self_test
# Description: run a sweep of a large number of possible passwords and validate that they all come back clean
# Returns: error if failure occurs
# End-Doc
sub handle_self_test {
    my $owner;
    if ( $^O =~ /win/i ) {
        $owner = "common";
    }
    else {
        $owner = ( getpwuid($<) )[0];
    }
    my $user     = "_SELF_TEST_";
    my $instance = "_SELF_TEST_";

    foreach my $len ( 1 .. 120 ) {
        my $pw = "x" x $len;
        open( my $out, "|authsrv-encrypt $owner $user $instance" );
        print $out $pw, "\n";
        close($out);

        open( my $in, "authsrv-decrypt $owner $user $instance|" );
        chomp( my $inpw = <$in> );
        close($in);

        if ( $inpw ne $pw ) {
            print "Failed self test with: $pw\n";
        }
    }

    system( "authsrv-delete", $owner, $user, $instance );
}
