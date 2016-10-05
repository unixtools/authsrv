all:
	cd .. && $(MAKE)

clean:
	cd .. && $(MAKE) clean

dist: clean
	cd .. && $(MAKE) dist

tidy:
	indent -linux -l120 *.[ch]
	rm -f *.[ch]~

