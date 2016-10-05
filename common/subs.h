struct DataBlock
{
	unsigned char *data;
	int length;
};

char *string_to_hex(char *src);

struct DataBlock *wrap_blowfish(struct DataBlock *key, struct DataBlock *data, int action);
struct DataBlock *FileToDataBlock(char *filename);
void DataBlockToFile(char *filename, struct DataBlock *data);
struct DataBlock *AllocDataBlock();
void FreeDataBlock(struct DataBlock *data);

void Log(char *action, char *owner, char *user, char *instance);

struct DataBlock *FetchHostKey(void);

char *get_fqdn(void);
char *check_element(char *str);
char *check_content(char *str);

#ifdef WINDOWS
#  define OUTPUT_ERROR(...) fprintf(stderr, __VA_ARGS__)
#else
#  define OUTPUT_ERROR(...) if(isatty(fileno(stderr))){ \
    fprintf(stderr, __VA_ARGS__); } else { \
    syslog(LOG_ERR, __VA_ARGS__); }
#endif

#define MAX_DATA_LEN 32000
