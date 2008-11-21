#include <stdio.h>
#ifndef WINDOWS
#include <pwd.h>
#endif
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#ifndef WINDOWS
#include <syslog.h>
#endif
#include "authsrv.h"
#include "blowfish.h"
#include "subs.h"

#define CheckNull(x) ((x)?(x):("Null"))

void Log(char *action, char *owner, char *user, char *instance)
{
#ifndef WINDOWS
	openlog("authsrv", LOG_PID | LOG_NOWAIT, LOG_AUTHPRIV);
	syslog(LOG_DEBUG, "Who(%d/%d) Action(%s) Owner(%s) User(%s) Instance(%s)",
		getuid(), 
		getgid(),
		CheckNull(action), 
		CheckNull(owner), 
		CheckNull(user), 
		CheckNull(instance));
#endif
}

char *check_element(char *str)
{
	int i;

	if ( !str )
	{
		return "must specify";
	}
        if ( strlen(str) > 40 )
        {
		return "too long";
        }

	for (i=0; i<strlen(str); i++)
	{
		char ch = str[i];

                if ( (ch >= 'A' && ch <= 'Z') ||
                        (ch >= 'a' && ch <= 'z') ||
                        (ch >= '0' && ch <= '9') ||
                        (ch == '@') ||
                        (ch == '-') ||
                        (ch == '_') ||
                        (ch == '+') ||
                        (ch == '=') ||
                        (ch == '.') )
                {
                        /* ok */
                }
                else
                {
			return "invalid character in string";
                }
	}


	return NULL;
}

char *check_content(char *str)
{
        if ( !str )
        {
                return "must specify";
        }
        if ( strlen(str) > MAX_DATA_LEN )
        {
                return "too long";
        }

        return NULL;
}


char *string_to_hex(char *src)
{
	int i;
	static char map[16] = 
		{'0','1','2','3','4','5','6','7',
		'8','9','A','B','C','D','E','F'};
	char *res = NULL;
	unsigned int tmp;

	res = (char *) malloc( strlen(src)*2 + 1 );

	for ( i=0; i<strlen(src); i++ )
	{
		tmp = src[i];
		res[2*i] = map[((tmp & 0xf0) >> 4)];
		res[2*i+1] = map[(tmp & 0x0f)];
	}
	res[2*i]='\0';

	return res;
}

char *DataBlockToHex(struct DataBlock *src)
{
	int i;
	static char map[16] = 
		{'0','1','2','3','4','5','6','7',
		'8','9','A','B','C','D','E','F'};
	char *res = NULL;
	unsigned int tmp;

	res = (char *) malloc( src->length *2 + 1 );
	for ( i=0; i<src->length; i++ )
	{
		tmp = src->data[i];
		res[2*i] = map[((tmp & 0xf0) >> 4)];
		res[2*i+1] = map[(tmp & 0x0f)];
	}
	res[2*i]='\0';

	return res;
}

struct DataBlock *wrap_blowfish(struct DataBlock *key, struct DataBlock *inblock, int action)
{
	BF_KEY bfkey;	
	unsigned char *tmpdata, *outdata;
	struct DataBlock *outblock;
	int len, i;

	if ( !inblock || !key || !inblock->data ) 
	{
		return NULL;
	}

	/* Calculate length that will be 8byte multiples */
	if ( inblock->length % 8 != 0 )
	{
		len = inblock->length + 8 - (inblock->length % 8);
	}
	else
	{
		len = inblock->length;
	}

	/* Allocate mem */
	outblock = (struct DataBlock *) malloc(sizeof(struct DataBlock));
	tmpdata = (unsigned char *) malloc(len);
	outdata = (unsigned char *) malloc(len);

	/* Initialize mem */
	outblock->data = outdata;
	outblock->length = len;
	memset(tmpdata, 0, len);
	memset(outdata, 0, len);
	memcpy(tmpdata, inblock->data, inblock->length);

	/* Set key */
	BF_set_key(&bfkey, key->length, key->data);

	/* Do encrypt/decrypt */
	for (i=0; i<len; i+=8)
	{
		BF_ecb_encrypt(&tmpdata[i], &outdata[i], &bfkey, action);
	}

	/* Return result */
	free(tmpdata);
	return outblock;
}


struct DataBlock *FileToDataBlock(char *filename)
{
	struct DataBlock *datablock;
	unsigned char tmpdata[MAX_DATA_LEN];
	FILE *file;

	datablock = (struct DataBlock *) malloc(sizeof(struct DataBlock));

	if ( (file=fopen(filename, "r")) == NULL )
	{
		fprintf(stderr, "Couldn't open file for reading:\n\t%s\n",filename);
		exit(1);
	}

	datablock->length = fread(tmpdata, sizeof(char), MAX_DATA_LEN, file);
	datablock->data = (unsigned char *) malloc(datablock->length);
	memcpy(datablock->data, tmpdata, datablock->length);
	fclose(file);
	return datablock;
}



void DataBlockToFile(char *filename, struct DataBlock *datablock)
{
	FILE *file;

	if ( (file=fopen(filename, "w")) == NULL )
	{
		fprintf(stderr, "Couldn't open file for writing:\n\t%s\n",filename);
		exit(1);
	}
	fwrite(datablock->data, sizeof(char), datablock->length, file);
	fclose(file);
}

struct DataBlock *FetchHostKey(void)
{
	struct DataBlock *key = NULL;

	key = FileToDataBlock(DATADIR "/host-key");
	if ( key->data[key->length] == '\n' )
	{
		key->data[key->length] = '\0';
	}

	return key;
}
