#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#ifndef WINDOWS
#include <pwd.h>
#endif
#include <fcntl.h>
#include <errno.h>
#include "authsrv.h"
#include "blowfish.h"
#include "subs.h"

int main(int argc, char *argv[])
{
	char *owner, *user, *instance;
	char filename[400];
	struct DataBlock data;
#ifndef WINDOWS
	struct passwd *userpw;
#endif
	char passwd[MAX_DATA_LEN];
	int i;

	umask(077);

	if ( argc != 4 )
	{
		fprintf(stderr,"Usage:\n");
		fprintf(stderr,"\t%s <owner> <user> <instance>\n", argv[0]);
		fprintf(stderr,"\t<owner> is the owner userid of this userid/password\n");
#ifdef WINDOWS
		fprintf(stderr,"\t<owner> is ignored on windows builds\n");
#endif
		fprintf(stderr,"\t<user> is the userid for this password\n");
		fprintf(stderr,"\t<instance> is the particular instance\n");
		fprintf(stderr,"\t<password> is passed via stdin\n");
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

#ifndef WINDOWS
	if ( !(userpw = getpwuid(getuid())) )
	{
		fprintf(stderr, "couldn't get real username\n");
		exit(1);
	}

	if ( getuid() != 0 && strcmp(owner,userpw->pw_name) )
	{
		fprintf(stderr, "owner does not match and you are not root\n");
		exit(1);
	}
#else
    /* No security on windows! Force owner to 'common' */
    owner = strdup("common");
#endif

	if ( ! fgets(passwd, MAX_DATA_LEN, stdin) )
	{
		fprintf(stderr, "Unable to read password.\n");
		exit(1);
	}
	for (i=0; i<=strlen(passwd); i++)
	{
		if (passwd[i] == '\n')
		{
			passwd[i] = 0;
		}
	}

	if ( check_content(passwd) )
	{
		fprintf(stderr, "error on password: %s\n", check_content(passwd));
		exit(1);
	}
	
	data.data = (unsigned char *) passwd;
	data.length = strlen(passwd)+1;

#ifndef WINDOWS
#define MKDIR(x,y) mkdir(x,y)
#else
#define MKDIR(x,y) mkdir(x)
#endif

	/* Make each directory and build the file name */
    sprintf(filename, DATADIR DIRSEP "keys" DIRSEP "%s",
        owner);
	if ( MKDIR(filename, 0755) == -1 && errno != EEXIST )
	{
		fprintf(stderr, "couldn't create dir (%s)\n", filename);
		exit(1);
	}

    sprintf(filename, DATADIR DIRSEP "keys" DIRSEP "%s" DIRSEP "%s",
        owner, user);
	if ( MKDIR(filename, 0755) == -1 && errno != EEXIST )
	{
		fprintf(stderr, "couldn't create dir (%s)\n", filename);
		exit(1);
	}

    sprintf(filename, DATADIR DIRSEP "keys" DIRSEP "%s" DIRSEP "%s" DIRSEP "%s",
        owner, user, instance);

	Log("encrypt", owner, user, instance);
	DataBlockToFile(filename, wrap_blowfish(FetchHostKey(),&data,BF_ENCRYPT));
	exit(0);
}

