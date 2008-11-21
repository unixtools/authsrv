BINDIR=/usr/bin
DATADIR=/usr/share/authsrv

LIBS = -L../blowfish -lblowfish
INC = -I../blowfish -I../common
CC = gcc -g -O2 -Wall -DDATADIR=\"$(DATADIR)\" -DDIRSEP=\"/\"

BFLIB = ../blowfish/libblowfish.a

all: auth encrypt decrypt delete list

build: 
	$(MAKE) clean
	$(MAKE) all
	$(MAKE) install

$(BFLIB):
	cd ../blowfish && $(MAKE)

auth: $(BFLIB) auth.o subs.o
	$(CC) -o auth auth.o subs.o $(LIBS) `krb5-config --libs`

auth.o: ../common/auth.c
	$(CC) $(INC) `krb5-config --cflags` -c -o auth.o ../common/auth.c

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

install: encrypt decrypt delete list dirs key
	strip encrypt
	strip decrypt
	strip delete
	strip list
	strip auth
	cp encrypt $(BINDIR)/authsrv-encrypt
	cp decrypt $(BINDIR)/authsrv-decrypt
	cp delete $(BINDIR)/authsrv-delete
	cp list $(BINDIR)/authsrv-list
	cp auth $(BINDIR)/authsrv-auth
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
	rm -f encrypt decrypt delete list auth
	cd ../blowfish && $(MAKE) clean

