#!/usr/bin/perl -t
#
# This is explicitly disabled here - we're running a system level tool
# setuid as a user, otherwise running directly as that user in normal
# cases.
#
no warnings qw(taint);

$ENV{PATH} = "/usr/bin";

use MIME::Base64;

$| = 1;

print "<authsrv>\n";

#
# Retrieve listing of authsrv stashes, and output each one
#
open( CMDIN, "/usr/bin/authsrv-list|" );
while ( chomp( my $line = <CMDIN> ) ) {
    my ( $owner, $user, $instance, $tstamp ) = split( /\//, $line );
	
	my @tmp = getpwnam($owner);
	next if ( $tmp[0] ne $owner );

	unless ( open(FETCH, "-|") )
	{
		if ( $> != $tmp[2] )
		{
		$) = $tmp[3];
		$( = $tmp[3];
		$< = $tmp[2];
		$> = $tmp[2];
		}
		exec("/usr/bin/authsrv-decrypt", $user, $instance);
		exit(0);
	};
	chomp(my $pw = <FETCH>);
	close(FETCH);

	my $encpw = encode_base64($pw, "");

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
