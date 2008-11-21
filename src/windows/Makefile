BINDIR=/usr/bin
DATADIR=C:\\\\authsrv

LIBS = -L../blowfish -lblowfish
INC = -I../blowfish -I../common
CC = gcc -g -O2 -Wall -DDATADIR=\"$(DATADIR)\" -DWINDOWS -DDIRSEP=\"\\\\\"

BFLIB = ../blowfish/libblowfish.a

all: encrypt decrypt delete list

build: 
	$(MAKE) clean
	$(MAKE) all
	$(MAKE) install

$(BFLIB):
	cd ../blowfish && $(MAKE)

encrypt: $(BFLIB) encrypt.o subs.o
	$(CC) -o encrypt encrypt.o subs.o $(LIBS)

encrypt.o: ../common/encrypt.c
	$(CC) $(INC) -c ../common/encrypt.c

decrypt: $(BFLIB) decrypt.o subs.o
	$(CC) -o decrypt decrypt.o subs.o $(LIBS)

decrypt.o: ../common/decrypt.c
	$(CC) $(INC) -c ../common/decrypt.c

delete: $(BFLIB) delete.o subs.o
	$(CC) -o delete delete.o subs.o $(LIBS)

delete.o: ../common/delete.c
	$(CC) $(INC) -c ../common/delete.c

list: $(BFLIB) list.o subs.o
	$(CC) -o list list.o subs.o $(LIBS)

list.o: ../common/list.c
	$(CC) $(INC) -c ../common/list.c

subs.o: ../common/subs.c
	$(CC) $(INC) -c ../common/subs.c

clean:
	rm -f *.a *.o 
	rm -f encrypt decrypt delete list 
	cd ../blowfish && $(MAKE) clean

