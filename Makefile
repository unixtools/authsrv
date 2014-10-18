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
	cp -pr ../src ../authsrv
	find ../authsrv -depth -name .svn -exec rm -rf {} \;
	rm -f ../binaries/authsrv.tar.gz
	cd .. && gtar -czvf binaries/authsrv.tar.gz authsrv
	rm -rf ../authsrv