BINDIR=/usr/bin
DATADIR=C:\\\\authsrv

LIBS = -L/lib -lssl -lcrypto -static
INC = -I../common
CC = gcc -g -O2 -Wall -DWINDOWS

all: authsrv-encrypt authsrv-decrypt authsrv-raw-encrypt authsrv-raw-decrypt authsrv-delete authsrv-list

build: 
	$(MAKE) clean
	$(MAKE) all
	$(MAKE) install

authsrv-encrypt: encrypt.o subs.o
	$(CC) -o authsrv-encrypt encrypt.o subs.o $(LIBS)

encrypt.o: ../common/encrypt.c
	$(CC) $(INC) -c ../common/encrypt.c

authsrv-raw-encrypt: encrypt-raw.o subs.o
	$(CC) -o authsrv-raw-encrypt encrypt-raw.o subs.o $(LIBS)

encrypt-raw.o: ../common/encrypt-raw.c
	$(CC) $(INC) -c ../common/encrypt-raw.c

authsrv-decrypt: decrypt.o subs.o
	$(CC) -o authsrv-decrypt decrypt.o subs.o $(LIBS)

decrypt.o: ../common/decrypt.c
	$(CC) $(INC) -c ../common/decrypt.c

authsrv-raw-decrypt: decrypt-raw.o subs.o
	$(CC) -o authsrv-raw-decrypt decrypt-raw.o subs.o $(LIBS)

decrypt-raw.o: ../common/decrypt-raw.c
	$(CC) $(INC) -c ../common/decrypt-raw.c

authsrv-delete: delete.o subs.o
	$(CC) -o authsrv-delete delete.o subs.o $(LIBS)

delete.o: ../common/delete.c
	$(CC) $(INC) -c ../common/delete.c

authsrv-list: list.o subs.o
	$(CC) -o authsrv-list list.o subs.o $(LIBS)

list.o: ../common/list.c
	$(CC) $(INC) -c ../common/list.c

subs.o: ../common/subs.c
	$(CC) $(INC) -c ../common/subs.c

clean:
	rm -f *.a *.o *.exe *~
	rm -f authsrv-encrypt authsrv-decrypt authsrv-delete authsrv-list authsrv-raw-encrypt authsrv-raw-decrypt

