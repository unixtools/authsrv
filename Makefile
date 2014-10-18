VERSION=3.0

all:
	if test -f /bin/make.exe; then \
		cd windows && $(MAKE); \
	else \
		cd unix && $(MAKE); \
	fi

clean:
	if test -f /bin/make.exe; then \
		cd windows && $(MAKE) clean; \
	else \
		cd unix && $(MAKE) clean; \
	fi

dist: clean
	rm -rf ../authsrv-$(VERSION)
	mkdir ../authsrv-$(VERSION)
	cp -pr . ../authsrv-$(VERSION)
	rm -f ../authsrv-$(VERSION)/*.gz
	gtar -C.. -czvf authsrv-$(VERSION).tar.gz authsrv-$(VERSION)
	rm -rf ../authsrv-$(VERSION)