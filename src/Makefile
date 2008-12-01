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
	cp -pr ../src ../authsrv-src
	find ../authsrv-src -depth -name .svn -exec rm -rf {} \;
	rm -f ../binaries/authsrv-src.tgz
	cd .. && gtar -czvf binaries/authsrv-src.tgz authsrv-src
	rm -rf ../authsrv-src