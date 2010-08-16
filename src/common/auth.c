#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <pwd.h>
#include "authsrv.h"
#include "blowfish.h"
#include "subs.h"
#include <syslog.h>
#include <krb5.h>

krb5_ccache krb5util_ccache = NULL;
krb5_context krb5util_context;

#ifdef WINDOWS
int main(int argc, char *argv[])
{
    exit(0);
}
#else

int authenticate(char *user, char *pass);

int main(int argc, char *argv[])
{
	char *user, *owner, *instance;
	char filename[400];
	struct passwd *userpw;
	struct DataBlock *encrypted, *decrypted;

	if ( argc < 2 )
	{
		fprintf(stderr,"Usage:\n");
		fprintf(stderr,"\t%s <user> [<instance>]\n", argv[0]);
		fprintf(stderr,"\t<user> is the userid\n");
		fprintf(stderr,"\t<instance> will default to 'ads'\n");
		exit(1);
	}	

	if ( !(userpw = getpwuid(getuid())) )
	{
		fprintf(stderr, "couldn't get real username\n");
		exit(1);
	}
	owner = strdup(userpw->pw_name);

	user = argv[1];
	if ( argc > 2 )
	{
		instance = argv[2];
	}
	else
	{
		instance = "ads";
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

    Log("decrypt", owner, user, instance);

    sprintf(filename, DATADIR DIRSEP "keys" DIRSEP "%s" DIRSEP "%s" DIRSEP "%s",
        owner, user, instance); 

	encrypted = FileToDataBlock(filename);
	decrypted = wrap_blowfish(FetchHostKey(),encrypted,BF_DECRYPT);

	/* switch back to real uid before authenticating so we can access ccache */
	setuid(getuid());

	/* now authenticate */
	authenticate(user, (char *) decrypted->data);
	exit(0);
}


int authenticate(char *user, char *pass)
{
	krb5_data tgtname = {
		0,
		KRB5_TGS_NAME_SIZE,
		KRB5_TGS_NAME
	};
	krb5_principal kprinc;
	krb5_principal server;
	krb5_creds kcreds;
	int options = 0;
	krb5_address **addrs = (krb5_address **)0;
	krb5_preauthtype *preauth = NULL;

	int used_own_krb5ccname = 0;
	int retval;
        static char ccache[100];

	/* Set the CCache to use */
	if ( ! getenv("KRB5CCNAME") )
	{
        sprintf(ccache, "KRB5CCNAME=/tmp/krb5cc_authsrv_u%d_p%d", getuid(), getpid());
        putenv(ccache);
		used_own_krb5ccname = 1;
	}

	/* Set ticket to be forwardable */
	options |= KDC_OPT_FORWARDABLE;

	if ( (retval=krb5_init_context(&krb5util_context)))
	{
		syslog(LOG_ERR, "init_context failed (%s)", error_message(retval));
		return 1;
	}

	if ( (retval = krb5_cc_default(krb5util_context, &krb5util_ccache)) )
	{
		syslog(LOG_ERR, "cc_default failed (%s)", error_message(retval));
		return 1;
	}


	if ( (retval = krb5_parse_name(krb5util_context, user, &kprinc)) )
	{
		syslog(LOG_ERR, "parse_name failed (%s)", error_message(retval));
		return 1;
	}

	memset((char *)&kcreds, 0, sizeof(kcreds));
	kcreds.client = kprinc;
	
	if ((retval = krb5_build_principal_ext(krb5util_context, &server,
		krb5_princ_realm(krb5util_context, kprinc)->length,
		krb5_princ_realm(krb5util_context, kprinc)->data,
		tgtname.length,
		tgtname.data,
		krb5_princ_realm(krb5util_context, kprinc)->length,
		krb5_princ_realm(krb5util_context, kprinc)->data,
		0)))
	{
		syslog(LOG_ERR, "build_princ failed (%s)", error_message(retval));
		return 1;
	}

	if ( (retval = krb5_cc_initialize(krb5util_context, krb5util_ccache,
		kprinc)) )
	{
		syslog(LOG_ERR, "cc_init failed (%s)", error_message(retval));
        krb5_cc_destroy(krb5util_context, krb5util_ccache);
		return 1;
	}

	kcreds.server = server;
	retval = krb5_get_in_tkt_with_password(krb5util_context,
		options,
		addrs,
		NULL,
		preauth,
		pass,
		krb5util_ccache,
		&kcreds,
		0);

	if ( retval )
	{
		syslog(LOG_ERR, "get_in_tkt failed (%s)", error_message(retval));
        krb5_cc_destroy(krb5util_context, krb5util_ccache);
		return 1;
	}

	if ( used_own_krb5ccname )
	{
        krb5_cc_destroy(krb5util_context, krb5util_ccache);
	}
	return(0);
}

#endif
