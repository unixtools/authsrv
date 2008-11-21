#!/usr/bin/perl
$| = 1;

&get_list();
while ( 1 )
{       
        print "\nAuthSrv: $STASHCOUNT stashed passwords\n";
	if ( $^O =~ /win/i )
	{
		print "Note: On windows, all stashes are merged into 'common' owner.\n";
	}
        print "Action: (S)tash (D)elete (L)ist (Q)uit: ";
        chomp($line = <STDIN>);
        last if ( !defined($line) ); 
        $line = lc $line;
        
        if ( $line eq "s" || $line eq "stash" )
        {
                &handle_stash();
        }
        elsif ( $line eq "d" || $line eq "delete" )
        {
                &handle_delete();
        }
        elsif ( $line eq "l" || $line eq "list" )
        {
                &handle_list();
        }
        elsif ( $line eq "q" || $line eq "quit" )
        {
                last;
        }       
}
                
print "\n";     
                        
sub get_list
{                       
        my $line;       
        open(CMDIN, "authsrv-list|");
        $STASHCOUNT = 0;
        %STASHED = ();          
        while ( chomp($line = <CMDIN>) )
        {                       
                my ($owner,$user,$instance,$tstamp) = split(/\//, $line);
                $STASHCOUNT++;  
                $STASHED{$owner}->{$user}->{$instance} = $tstamp;
        }                               
        close(CMDIN);                   
}                                       
                                                
sub handle_list                         
{                               
        my $last_owner; 
        my $last_user;
        
	if ( $STASHCOUNT == 0 )
	{
		print "\n";
		print "There are currently no passwords stashed that you have access to.\n";
		return;
	}
	
        print "\n";
        print "Currently Stashed Passwords ($STASHCOUNT):\n";
        print "--------------------------------------------------------------------\n";
        print "Owner    User     Instance           Modification Time\n";
        print "--------------------------------------------------------------------\n";
        foreach my $owner ( sort(keys(%STASHED)) )
        {
                foreach my $user ( sort(keys(%{ $STASHED{$owner} })) )
                {
                        foreach my $instance ( sort(keys(%{ $STASHED{$owner}->{$user} })) )
                        {
                                my $ou = $owner . "\0" . $user;
                                if ( $ou ne $last_ou )
                                {
                                        print "$owner\n";
                                        print " \\------ $user\n";
                                        $last_ou = $ou;
                                }

                                print "          \\------ $instance    ";
				print " "x(15-length($instance));
				print scalar(localtime( $STASHED{$owner}->{$user}->{$instance})), "\n";
                        }
                }
        }
        print "\n";
}


sub handle_stash
{
        print "\n";

        print "Enter information for new or updated stash:\n";
        my $owner = &prompt_owner() || return;
        my $user = &prompt("User") || return;
        my $instance = &prompt("Instance") || return;
        my $pw = &prompt_pw() || return;

        print "\n";
	if ( $^O !~ /win/i )
	{
        	open(CMD, "|-") || exec("authsrv-encrypt", $owner, $user, $instance);
	}
	else
	{
		open(CMD, "|authsrv-encrypt $owner $user $instance");
	}
        print CMD $pw, "\n";
        close(CMD);
        print "\n";

        &get_list();
}


sub handle_delete
{
        my ($owner, $user, $instance);

        print "\n";
        print "Enter information to delete a stash:\n";
        print "Enter * to delete all matching entries.\n";

        $owner = &prompt_owner() || return;
        if ( $owner ne "*" )
        {
                $user = &prompt("User") || return;
        }
        else
        {
                $user = "*";
        }
        if ( $user ne "*" )
        {
                $instance = &prompt("Instance") || return;
        }
        else
        {
                $instance = "*";
        }

        foreach my $fowner ( sort(keys(%STASHED)) )
        {
                next if ( $owner ne $fowner && $owner ne "*" );

                foreach my $fuser ( sort(keys(%{ $STASHED{$fowner} })) )
                {
                        next if ( $user ne $fuser && $user ne "*" );

                        foreach my $finstance ( sort(keys(%{ $STASHED{$fowner}->{$fuser} })) )
                        {
                                next if ( $instance ne $finstance && $instance ne "*" );

                                print "Delete $fowner / $fuser / $finstance (Y/N)? ";
                                my $yn;
                                chomp($yn = <STDIN>);
                                if ( $yn =~ /^\s*y/io )
                                {
                                        print "  deleting $fowner / $fuser / $finstance:\n";
                                        system("authsrv-delete", $fowner, $fuser, $finstance);
                                        if ( $? )
                                        {
						print "\n";
					}
				}
			}
		}
	}
	
	&get_list();
}

sub prompt_owner
{
	my $owner;
	
	if ( $^O =~ /win/i )
	{
		$owner = "common";
		print "Owner: $owner\n";
	}
	elsif ( $< == 0 )
	{
		print "Owner: ";
		chomp($owner = <STDIN>);
	}
	else
	{
		$owner = ( getpwuid($<) )[0];
		print "Owner: $owner\n";
	}
	return $owner;	
}

sub prompt
{
	my $label = shift;
	print "$label: ";
	my $str;
	chomp($str = <STDIN>);
	return $str;
}

sub prompt_pw
{
	my ($pw, $pw2);
	
	print "Password: ";
	if ( $^O !~ /win/i )
	{
		system("stty -echo");
	}
	chomp($pw = <STDIN>);
	print "\n";
	
	print "Verify: ";
	chomp($pw2 = <STDIN>);
	print "\n";
	if ( $^O !~ /win/i )
	{
		system("stty echo");
	}

	if ( $pw eq $pw2 )
	{
		return $pw;
	}
	else
	{
		print "Passwords do not match!\n";
		return undef;
	}
}
