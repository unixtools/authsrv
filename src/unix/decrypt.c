#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <pwd.h>
#include "blowfish.h"
#include "subs.h"

int main(int argc, char *argv[])
{
	char res[21];
	char *user, *instance, *owner;
	char filename[400];
	struct passwd *userpw;
	struct DataBlock *encrypted, *decrypted;

	if ( argc != 3 )
	{
		fprintf(stderr,"Usage:\n");
		fprintf(stderr,"\t%s <user> <instance>\n", argv[0]);
		fprintf(stderr,"\t<user> is the userid\n");
		fprintf(stderr,"\t<instance> is the instance\n");
		exit(1);
	}	
	res[20] = 0;

	if ( !(userpw = getpwuid(getuid())) )
	{
		fprintf(stderr, "couldn't get real username\n");
		exit(1);
	}
	owner = strdup(userpw->pw_name);

	user = argv[1];
	instance = argv[2];

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

	Log("decrypt", owner, user, instance);
	sprintf(filename, DATADIR "/keys/%s/%s/%s",
		owner, user, instance);

	encrypted = FileToDataBlock(filename);
	decrypted = wrap_blowfish(FetchHostKey(),encrypted,BF_DECRYPT);
	printf("%s\n", decrypted->data);
	exit(0);
}

