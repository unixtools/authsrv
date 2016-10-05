#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <errno.h>
#include <syslog.h>
#include "authsrv.h"
#include "subs.h"

int main(int argc, char *argv[])
{
	char *owner, *user, *instance;
	char filename[400];

	if ( argc != 4 )
	{
		fprintf(stderr,"Usage:\n");
		fprintf(stderr,"\t%s <owner> <user> <instance>\n", argv[0]);
		fprintf(stderr,"\t<owner> is the owner userid of this userid/password\n");
		fprintf(stderr,"\t<user> is the userid for this password\n");
		fprintf(stderr,"\t<instance> is the particular instance\n");
		exit(1);
	}	

	owner = argv[1];
	user = argv[2];
	instance = argv[3];

	/* Check if valid */
	if ( !owner || !user || !instance )
	{
        Log("error-params", owner, user, instance);
		OUTPUT_ERROR( "Invalid parameters.\n");
		exit(1);
	}

    if ( check_element(owner) )
    {
        Log("error-owner", owner, user, instance);
        OUTPUT_ERROR( "error on owner: %s\n", check_element(owner));
        exit(1);
    }
    if ( check_element(user) )
    {
        Log("error-user", owner, user, instance);
        OUTPUT_ERROR( "error on user: %s\n", check_element(user));
        exit(1);
    }
    if ( check_element(instance) )
    {
        Log("error-instance", owner, user, instance);
        OUTPUT_ERROR( "error on instance: %s\n", check_element(instance));
        exit(1);
    }

	/* Make each directory and build the file name */
    sprintf(filename, DATADIR DIRSEP "keys" DIRSEP "%s" DIRSEP "%s" DIRSEP "%s",
        owner, user, instance);
	Log("delete", owner, user, instance);
	unlink(filename);

	/* Now try to unlink dirs if empty */
    sprintf(filename, DATADIR DIRSEP "keys" DIRSEP "%s" DIRSEP "%s",
        owner, user);
	Log("delete", owner, user, instance);
	if ( rmdir(filename) )
	{
		exit(0);
	}

    sprintf(filename, DATADIR DIRSEP "keys" DIRSEP "%s",
        owner);
	if ( rmdir(filename) )
	{
		exit(0);
	}

	exit(0);
}

