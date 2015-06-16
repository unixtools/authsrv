VERSION=3.1.0

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
	rm -rf /tmp/authsrv-$(VERSION)
	mkdir /tmp/authsrv-$(VERSION)
	cp -pr . /tmp/authsrv-$(VERSION)
	cd /tmp/authsrv-$(VERSION) && rm -rf *.gz .git .gitignore
	tar -C/tmp -czvf authsrv-$(VERSION).tar.gz authsrv-$(VERSION)
	rm -rf /tmp/authsrv-$(VERSION)

deb: dist
	cp authsrv-$(VERSION).tar.gz ../authsrv_$(VERSION).orig.tar.gz
	dpkg-buildpackage -b
	rm -f ../authsrv_$(VERSION).orig.tar.gz
