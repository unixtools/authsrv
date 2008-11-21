#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <errno.h>
#include "blowfish.h"
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
		fprintf(stderr, "Invalid parameters.\n");
		exit(1);
	}


        if ( check_element(owner) )
        {
                fprintf(stderr, "error on owner: %s\n", check_element(owner));
                exit(1);
        }
        if ( check_element(user) )
        {
                fprintf(stderr, "error on user: %s\n", check_element(user));
                exit(1);
        }
        if ( check_element(instance) )
        {
                fprintf(stderr, "error on instance: %s\n", check_element(instance));
                exit(1);
        }

	/* Make each directory and build the file name */
	strcpy(filename, DATADIR "/keys/");
	strcat(filename, owner);
	strcat(filename, "/");
	strcat(filename, user);
	strcat(filename, "/");
	strcat(filename, instance);

	Log("delete", owner, user, instance);
	unlink(filename);

	/* Now try to unlink dirs if empty */
	strcpy(filename, DATADIR "/keys/");
	strcat(filename, owner);
	strcat(filename, "/");
	strcat(filename, user);
	if ( rmdir(filename) )
	{
		exit(0);
	}

	strcpy(filename, DATADIR "/keys/");
	strcat(filename, owner);
	if ( rmdir(filename) )
	{
		exit(0);
	}

	exit(0);
}

