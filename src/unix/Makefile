BINDIR=/usr/bin
DATADIR=/usr/share/authsrv

LIBS = -L../blowfish -lblowfish
INC = -I../blowfish -I../common
CC = gcc -g -O2 -Wall 

BFLIB = ../blowfish/libblowfish.a

all: authsrv-auth authsrv-encrypt authsrv-decrypt authsrv-delete authsrv-list

build: 
	$(MAKE) clean
	$(MAKE) all
	$(MAKE) install

$(BFLIB):
	cd ../blowfish && $(MAKE)

authsrv-auth: $(BFLIB) auth.o subs.o
	$(CC) -o authsrv-auth auth.o subs.o $(LIBS) `krb5-config --libs`

auth.o: ../common/auth.c
	$(CC) $(INC) `krb5-config --cflags` -c -o auth.o ../common/auth.c

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

install: authsrv-encrypt authsrv-decrypt authsrv-delete authsrv-list authsrv-dirs key
	strip authsrv-encrypt
	strip authsrv-decrypt
	strip authsrv-delete
	strip authsrv-list
	strip authsrv-auth
	cp authsrv-encrypt $(BINDIR)/authsrv-encrypt
	cp authsrv-decrypt $(BINDIR)/authsrv-decrypt
	cp authsrv-delete $(BINDIR)/authsrv-delete
	cp authsrv-list $(BINDIR)/authsrv-list
	cp authsrv-auth $(BINDIR)/authsrv-auth
	-chmod 4755 $(BINDIR)/authsrv-*
	-chmod 755 $(DATADIR)/keys
	-chmod 600 $(DATADIR)/host-key

dirs:
	mkdir -p $(DATADIR)/keys
	chmod 700 $(DATADIR) $(DATADIR)/keys

key: dirs $(DATADIR)/host-key

$(DATADIR)/host-key:
	umask 077 && head -64c /dev/random > $(DATADIR)/host-key
	chmod 400 $(DATADIR)/host-key

clean:
	rm -f *.a *.o 
	rm -f authsrv-encrypt authsrv-decrypt authsrv-delete authsrv-list authsrv-auth
	cd ../blowfish && $(MAKE) clean

