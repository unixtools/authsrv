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
#include <syslog.h>
#include <openssl/blowfish.h>
#include "authsrv.h"
#include "subs.h"

int main(int argc, char *argv[])
{
	char *owner, *user, *instance;
	char filename[400];
	struct DataBlock *data, *encrypted, *hk;
#ifndef WINDOWS
	struct passwd *userpw;
#endif
	int curlen = 0;
	char buf[MAX_DATA_LEN] = "";
	char passwd[MAX_DATA_LEN] = "";
	int i;

	umask(077);

	if (argc != 4) {
		fprintf(stderr, "Usage:\n");
		fprintf(stderr, "\t%s <owner> <user> <instance>\n", argv[0]);
		fprintf(stderr, "\t<owner> is the owner userid of this userid/password\n");
#ifdef WINDOWS
		fprintf(stderr, "\t<owner> is ignored on windows builds\n");
#endif
		fprintf(stderr, "\t<user> is the userid for this password\n");
		fprintf(stderr, "\t<instance> is the particular instance\n");
		fprintf(stderr, "\t<password> is passed via stdin\n");
		exit(1);
	}

	owner = argv[1];
	user = argv[2];
	instance = argv[3];

	/* Check if valid */
	if (!owner || !user || !instance) {
		Log("error-parameters", owner, user, instance);
		OUTPUT_ERROR("Invalid parameters.\n");
		exit(1);
	}

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
#ifndef WINDOWS
	if (!(userpw = getpwuid(getuid()))) {
		Log("error-username", owner, user, instance);
		OUTPUT_ERROR("couldn't get real username\n");
		exit(1);
	}

	if (getuid() != 0 && strcmp(owner, userpw->pw_name)) {
		Log("error-mismatch", owner, user, instance);
		OUTPUT_ERROR("owner does not match and you are not root\n");
		exit(1);
	}
#else
	/* No security on windows! Force owner to 'common' */
	owner = strdup("common");
#endif

	buf[0] = 0;
	curlen = 0;
	passwd[0] = 0;

	while (curlen < (MAX_DATA_LEN - 1000)) {
		i = read(fileno(stdin), buf, 1000);
		if (i > 0) {
			memcpy(passwd + curlen, buf, i);
			curlen += i;
		} else {
			break;
		}
	}

	if (curlen == 0) {
		Log("error-pwlen", owner, user, instance);
		OUTPUT_ERROR("error on password: must be specified\n");
		exit(1);
	}

	if (check_content(passwd)) {
		Log("error-pw", owner, user, instance);
		OUTPUT_ERROR("error on password: %s\n", check_content(passwd));
		exit(1);
	}

	data = AllocDataBlock();
	data->data = (unsigned char *)passwd;
	data->length = strlen(passwd) + 1;

#ifndef WINDOWS
#define MKDIR(x,y) mkdir(x,y)
#else
#define MKDIR(x,y) mkdir(x)
#endif

	/* Make each directory and build the file name */
	sprintf(filename, DATADIR DIRSEP "keys" DIRSEP "%s", owner);
	if (MKDIR(filename, 0755) == -1 && errno != EEXIST) {
		Log("error-mkdir1", owner, user, instance);
		OUTPUT_ERROR("couldn't create dir (%s)\n", filename);
		exit(1);
	}

	sprintf(filename, DATADIR DIRSEP "keys" DIRSEP "%s" DIRSEP "%s", owner, user);
	if (MKDIR(filename, 0755) == -1 && errno != EEXIST) {
		Log("error-mkdir2", owner, user, instance);
		OUTPUT_ERROR("couldn't create dir (%s)\n", filename);
		exit(1);
	}

	sprintf(filename, DATADIR DIRSEP "keys" DIRSEP "%s" DIRSEP "%s" DIRSEP "%s", owner, user, instance);

	Log("encrypt", owner, user, instance);
	hk = FetchHostKey();

	encrypted = wrap_blowfish(hk, data, BF_ENCRYPT);
	FreeDataBlock(hk);

	DataBlockToFile(filename, encrypted);
	FreeDataBlock(encrypted);

	data->data = 0;
	FreeDataBlock(data);

	exit(0);
}
