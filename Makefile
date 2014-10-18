all:
	cd src && $(MAKE)

clean:
	cd src && $(MAKE) clean

dist: clean
	cd src && $(MAKE) dist