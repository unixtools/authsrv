BINDIR=/usr/bin
DATADIR=/usr/share/authsrv

LIBS = -L../blowfish -lblowfish
INC = -I../blowfish -I../common
CC = gcc -g -O2 -Wall 

INSTALL = install -c

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

# Do not put key on this, otherwise will include a key in an RPM build
install: dirs authsrv-encrypt authsrv-decrypt authsrv-delete authsrv-list
	$(INSTALL) -m 4755 -o root -g root authsrv-encrypt $(BINDIR)
	$(INSTALL) -m 4755 -o root -g root authsrv-decrypt $(BINDIR)
	$(INSTALL) -m 4755 -o root -g root authsrv-delete $(BINDIR)
	$(INSTALL) -m 4755 -o root -g root authsrv-list $(BINDIR)
	$(INSTALL) -m 4755 -o root -g root authsrv-auth $(BINDIR)
	$(INSTALL) -m 755 -o root -g root ../scripts/authsrv-dump.pl $(BINDIR)/authsrv-dump
	$(INSTALL) -m 755 -o root -g root ../scripts/authsrv-load.pl $(BINDIR)/authsrv-load
	$(INSTALL) -m 755 -o root -g root ../scripts/authsrv.pl $(BINDIR)/authsrv

dirs:
	mkdir -p $(BINDIR)
	mkdir -p $(DATADIR)/keys
	chmod 700 $(DATADIR) $(DATADIR)/keys

key: dirs $(DATADIR)/host-key

$(DATADIR)/host-key:
	-touch $(DATADIR)/host-key
	-chmod 600 $(DATADIR)/host-key
	umask 077 && head -64c /dev/random > $(DATADIR)/host-key
	chmod 400 $(DATADIR)/host-key

clean:
	rm -f *.a *.o 
	rm -f authsrv-encrypt authsrv-decrypt authsrv-delete authsrv-list authsrv-auth
	cd ../blowfish && $(MAKE) clean

