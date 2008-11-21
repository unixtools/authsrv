BINDIR=/usr/bin
DATADIR=C:\\\\authsrv

LIBS = -L../blowfish -lblowfish
INC = -I../blowfish -I../common
CC = gcc -g -O2 -Wall -DWINDOWS

BFLIB = ../blowfish/libblowfish.a

all: authsrv-encrypt authsrv-decrypt authsrv-delete authsrv-list

build: 
	$(MAKE) clean
	$(MAKE) all
	$(MAKE) install

$(BFLIB):
	cd ../blowfish && $(MAKE)

authsrv-encrypt: $(BFLIB) encrypt.o subs.o
	$(CC) -o authsrv-encrypt encrypt.o subs.o $(LIBS)

encrypt.o: ../common/encrypt.c
	$(CC) $(INC) -c ../common/encrypt.c

authsrv-decrypt: $(BFLIB) decrypt.o subs.o
	$(CC) -o authsrv-decrypt decrypt.o subs.o $(LIBS)

decrypt.o: ../common/decrypt.c
	$(CC) $(INC) -c ../common/decrypt.c

authsrv-delete: $(BFLIB) delete.o subs.o
	$(CC) -o authsrv-delete delete.o subs.o $(LIBS)

delete.o: ../common/delete.c
	$(CC) $(INC) -c ../common/delete.c

authsrv-list: $(BFLIB) list.o subs.o
	$(CC) -o authsrv-list list.o subs.o $(LIBS)

list.o: ../common/list.c
	$(CC) $(INC) -c ../common/list.c

subs.o: ../common/subs.c
	$(CC) $(INC) -c ../common/subs.c

clean:
	rm -f *.a *.o *.exe *~
	rm -f authsrv-encrypt authsrv-decrypt authsrv-delete authsrv-list 
	cd ../blowfish && $(MAKE) clean

