#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#ifndef WINDOWS
#include <pwd.h>
#endif
#include <syslog.h>
#include <openssl/blowfish.h>
#include "authsrv.h"
#include "subs.h"

int main(int argc, char *argv[])
{
	char *user, *instance, *owner = NULL;
	char filename[400];
#ifndef WINDOWS
	struct passwd *userpw;
#endif
	struct DataBlock *encrypted, *decrypted, *hk;

	if (argc != 3 && argc != 4) {
		fprintf(stderr, "Usage:\n");
		fprintf(stderr, "\t%s [<owner>] <user> <instance>\n", argv[0]);
		fprintf(stderr, "\t<owner> is the owning userid\n");
		fprintf(stderr, "\t<user> is the userid\n");
		fprintf(stderr, "\t<instance> is the instance\n");
		exit(1);
	}

	if (argc == 3) {
		user = argv[1];
		instance = argv[2];
	} else {
		owner = argv[1];
		user = argv[2];
		instance = argv[3];
	}

#ifndef WINDOWS
	if (!(userpw = getpwuid(getuid()))) {
		Log("error-username", owner, user, instance);
		OUTPUT_ERROR("couldn't get real username\n");
		exit(1);
	}

	if (!owner) {
		owner = strdup(userpw->pw_name);
	} else if (getuid() != 0 && strcmp(owner, userpw->pw_name)) {
		Log("error-username", owner, user, instance);
		OUTPUT_ERROR("owner does not match and you are not root\n");
		exit(1);
	}
#else
	/* No security on windows! Force owner to 'common' */
	owner = strdup("common");
#endif

	if (check_element(owner)) {
		Log("error-owner", owner, user, instance);
		OUTPUT_ERROR("error on owner: %s\n", check_element(owner));
		exit(1);
	}
	if (check_element(user)) {
		Log("error-user", owner, user, instance);
		OUTPUT_ERROR("error on user: %s\n", check_element(user));
		exit(1);
	}
	if (check_element(instance)) {
		Log("error-instance", owner, user, instance);
		OUTPUT_ERROR("error on instance: %s\n", check_element(instance));
		exit(1);
	}

	Log("decrypt", owner, user, instance);

	sprintf(filename, DATADIR DIRSEP "keys" DIRSEP "%s" DIRSEP "%s" DIRSEP "%s", owner, user, instance);

	encrypted = FileToDataBlock(filename);

	hk = FetchHostKey();
	decrypted = wrap_blowfish(hk, encrypted, BF_DECRYPT);
	FreeDataBlock(hk);

	/* no trailing newline */
	printf("%s", decrypted->data);

	FreeDataBlock(encrypted);
	FreeDataBlock(decrypted);
	exit(0);
}
