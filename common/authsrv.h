
#ifndef DIRSEP
#ifdef WINDOWS
#define DIRSEP "\\"
#else
#define DIRSEP "/"
#endif
#endif

#ifndef DATADIR
#ifdef WINDOWS
#define DATADIR "C:\\authsrv"
#else
#define DATADIR "/usr/share/authsrv"
#endif
#endif
