VERSION=3.1.1

all:
	if test -f /bin/make.exe; then \
		cd windows && $(MAKE); \
	else \
		cd unix && $(MAKE); \
	fi

install:
	if test -f /bin/make.exe; then \
		cd windows && $(MAKE) install; \
	else \
		cd unix && $(MAKE) install; \
	fi

clean:
	if test -f /bin/make.exe; then \
		cd windows && $(MAKE) clean; \
	else \
		cd unix && $(MAKE) clean; \
	fi
	rm -rf debian/authsrv debian/tmp debian/authsrv.substvars debian/files

key:
	if test -f /bin/make.exe; then \
		cd windows && $(MAKE) key; \
	else \
		cd unix && $(MAKE) key; \
	fi

dist: clean
	rm -rf /tmp/authsrv-$(VERSION)
	mkdir /tmp/authsrv-$(VERSION)
	cp -pr . /tmp/authsrv-$(VERSION)
	cd /tmp/authsrv-$(VERSION) && rm -rf *.gz .git .gitignore
	tar -C/tmp -czvf ../authsrv-$(VERSION).tar.gz authsrv-$(VERSION)
	rm -rf /tmp/authsrv-$(VERSION)

deb: dist
	rm -f ../authsrv_$(VERSION).orig.tar.gz
	ln ../authsrv-$(VERSION).tar.gz ../authsrv_$(VERSION).orig.tar.gz
	dpkg-buildpackage -us -uc
	rm -f ../authsrv_$(VERSION).orig.tar.gz
