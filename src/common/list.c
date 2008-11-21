#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#ifndef WINDOWS
#include <pwd.h>
#endif
#include <sys/types.h>
#include <dirent.h>
#include <sys/stat.h>
#include "authsrv.h"
#include "blowfish.h"
#include "subs.h"


void scan_owners(char *owner, char *user, char *instance);
void scan_users(char *owner, char *user, char *instance);
void scan_instances(char *owner, char *user, char *instance);

int main(int argc, char *argv[])
{
	char res[21];
	char *user = NULL, *instance = NULL, *owner = NULL;
#ifndef WINDOWS
	struct passwd *userpw;
#endif

	if ( (argc == 2 || argc > 4) && !strcmp(argv[1], "-h") )
	{
		fprintf(stderr,"Usage:\n");
		fprintf(stderr,"\t%s <owner> <user> <instance>\n", argv[0]);
		fprintf(stderr,"\t<owner> is the owner to list (optional)\n");
		fprintf(stderr,"\t<user> is the user to list (optional)\n");
		fprintf(stderr,"\t<instance> is the instance to list (optional)\n");
		exit(1);
	}	
	res[20] = 0;

#ifndef WINDOWS
	if ( !(userpw = getpwuid(getuid())) )
	{
		fprintf(stderr, "couldn't get real username\n");
		exit(1);
	}
#endif

	if ( argc > 1 )
	{
		owner = argv[1];
	}
	
	if ( argc > 2 )
	{
		user = argv[2];
	}
	
	if ( argc > 3 )
	{
		instance = argv[3];
	}

#ifndef WINDOWS
	if ( getuid() != 0 && !owner )
	{
		owner = strdup(userpw->pw_name);
	}

    if ( getuid() != 0 && owner && strcmp(owner,userpw->pw_name) )
    {
        fprintf(stderr, "owner does not match and you are not root\n");
        exit(1);
    }
#else
    /* owner forced to 'common' on windows */
    owner = strdup("common");
#endif

    if ( owner && check_element(owner) )
    {
        fprintf(stderr, "error on owner: %s\n", check_element(owner));
        exit(1);
    }
    if ( user && check_element(user) )
    {
        fprintf(stderr, "error on user: %s\n", check_element(user));
        exit(1);
    }
    if ( instance && check_element(instance) )
    {
        fprintf(stderr, "error on instance: %s\n", check_element(instance));
        exit(1);
    }

	Log("list", owner ? owner : "*", user ? user : "*", instance ? instance : "*" );

	scan_owners(owner, user, instance);
	exit(0);
}

void scan_owners(char *owner, char *user, char *instance)
{
	DIR *dirh;
	struct stat tmpstat;
	char tmpfile[500];
	char filename[400];
	struct dirent *fh;
		
	sprintf(filename, DATADIR "/keys");
	dirh = opendir(filename);
	if ( ! dirh )
	{
        return;
	}
	while ( (fh = readdir(dirh)) )
	{
		char *fn = fh->d_name;
		if ( !fn ) continue;

		/* if owner doesn't match, skip it */
		if ( owner && strcmp(owner, fn) ) continue;

		/* skip anything that couldn't be a valid owner */
		if ( !strcmp(fn, ".") || !strcmp(fn, "..") ) continue;

		/* skip anything we don't consider valid */
		if ( check_element(fn) ) continue;

		/* stat it and skip if not a directory */
		sprintf(tmpfile, DATADIR DIRSEP "keys" DIRSEP "%s", fn);
		if ( lstat(tmpfile, &tmpstat) ) continue;
		if ( ! S_ISDIR(tmpstat.st_mode) ) continue;
		
		scan_users(fn, user, instance);		
	}
	closedir(dirh);
}

void scan_users(char *owner, char *user, char *instance)
{
	DIR *dirh;
	struct stat tmpstat;
	char tmpfile[500];
	char filename[400];
	struct dirent *fh;
		
	sprintf(filename, DATADIR DIRSEP "keys" DIRSEP "%s", owner);
	dirh = opendir(filename);
	if ( ! dirh )
	{
        return;
	}
	while ( (fh = readdir(dirh)) )
	{
		char *fn = fh->d_name;
		if ( !fn ) continue;

		/* if owner doesn't match, skip it */
		if ( user && strcmp(user, fn) ) continue;

		/* skip anything that couldn't be a valid owner */
		if ( !strcmp(fn, ".") || !strcmp(fn, "..") ) continue;

		/* skip anything we don't consider valid */
		if ( check_element(fn) ) continue;

		/* stat it and skip if not a directory */
		sprintf(tmpfile, DATADIR DIRSEP "keys" DIRSEP "%s" DIRSEP "%s", owner, fn);
		if ( lstat(tmpfile, &tmpstat) ) continue;
		if ( ! S_ISDIR(tmpstat.st_mode) ) continue;
		
		scan_instances(owner, fn, instance);		
	}
	closedir(dirh);
}

void scan_instances(char *owner, char *user, char *instance)
{
	DIR *dirh;
	struct stat tmpstat;
	char tmpfile[500];
	char filename[400];
	struct dirent *fh;
		
	sprintf(filename, DATADIR DIRSEP "keys" DIRSEP "%s" DIRSEP "%s", owner, user);
	dirh = opendir(filename);
	if ( ! dirh )
	{
        return;
	}
	while ( (fh = readdir(dirh)) )
	{
		char *fn = fh->d_name;
		if ( !fn ) continue;

		/* if owner doesn't match, skip it */
		if ( instance && strcmp(instance, fn) ) continue;

		/* skip anything that couldn't be a valid owner */
		if ( !strcmp(fn, ".") || !strcmp(fn, "..") ) continue;

		/* skip anything we don't consider valid */
		if ( check_element(fn) ) continue;

		/* stat it and skip if not a directory */
		sprintf(tmpfile, DATADIR DIRSEP "keys" DIRSEP "%s" DIRSEP "%s" DIRSEP "%s", owner, user, fn);
		if ( lstat(tmpfile, &tmpstat) ) continue;
		if ( ! S_ISREG(tmpstat.st_mode) ) continue;
		
		printf("%s/%s/%s/%u\n", owner, user, fn, (unsigned int) tmpstat.st_mtime);
	}
	closedir(dirh);
}
