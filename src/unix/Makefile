BINDIR=/usr/bin
DATADIR=/usr/share/authsrv

LIBS = -lssl -lcrypto
INC = -I../common
CC = gcc -g -O2 -Wall -DDATADIR=\"$(DATADIR)\"

INSTALL = install -c

all: authsrv-auth authsrv-encrypt authsrv-decrypt authsrv-delete authsrv-list authsrv-raw-encrypt authsrv-raw-decrypt

build: 
	$(MAKE) clean
	$(MAKE) all
	$(MAKE) install

authsrv-auth: auth.o subs.o
	$(CC) -o authsrv-auth auth.o subs.o $(LIBS) `krb5-config --libs`

auth.o: ../common/auth.c
	$(CC) $(INC) `krb5-config --cflags` -c -o auth.o ../common/auth.c

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

# Do not put key on this, otherwise will include a key in an RPM build
install: dirs authsrv-encrypt authsrv-decrypt authsrv-raw-encrypt authsrv-raw-decrypt authsrv-delete authsrv-list
	$(INSTALL) -m 4755 -o root -g root authsrv-encrypt $(BINDIR)
	$(INSTALL) -m 4755 -o root -g root authsrv-decrypt $(BINDIR)
	$(INSTALL) -m 4755 -o root -g root authsrv-raw-encrypt $(BINDIR)
	$(INSTALL) -m 4755 -o root -g root authsrv-raw-decrypt $(BINDIR)
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
	rm -f authsrv-encrypt authsrv-decrypt authsrv-delete authsrv-list authsrv-auth authsrv-raw-encrypt authsrv-raw-decrypt

