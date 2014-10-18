struct DataBlock
{
	unsigned char *data;
	int length;
};

char *string_to_hex(char *src);

struct DataBlock *wrap_blowfish(struct DataBlock *key, struct DataBlock *data, int action);
struct DataBlock *FileToDataBlock(char *filename);
void DataBlockToFile(char *filename, struct DataBlock *data);

void Log(char *action, char *owner, char *user, char *instance);

struct DataBlock *FetchHostKey(void);

char *get_fqdn(void);
char *check_element(char *str);
char *check_content(char *str);

#define MAX_DATA_LEN 32000
