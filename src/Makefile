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