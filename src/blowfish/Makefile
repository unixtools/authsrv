
CC=gcc
CFLAGS= -DBF_PTR2 -O4 -funroll-loops -fomit-frame-pointer

LIBOBJ=bf_skey.o bf_ecb.o bf_enc.o bf_cbc.o bf_cfb64.o bf_ofb64.o

BLIB=	libblowfish.a

all: $(BLIB)

test: bftest
	./bftest

speed: bfspeed
	./bfspeed

$(BLIB): $(LIBOBJ)
	rm -f $(BLIB)
	ar cr $(BLIB) $(LIBOBJ)

bftest: bftest.o $(BLIB)
	$(CC) $(CFLAGS) -o bftest bftest.o $(BLIB)

bfspeed: bfspeed.o $(BLIB)
	$(CC) $(CFLAGS) -o bfspeed bfspeed.o $(BLIB)

clean:
	rm -f *.o tags core bftest bfspeed *.a .nfs* *.old *.bak asm/*.o *.exe *.lib
