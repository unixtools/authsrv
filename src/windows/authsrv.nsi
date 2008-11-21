# define installer name
outFile "install-authsrv.exe"
 
# set desktop as install directory
installDir $WINDIR
 
# default section start
section
 
# define output path
setOutPath $INSTDIR
 
# specify file to go in output path
file authsrv-decrypt.exe
file authsrv-encrypt.exe
file authsrv-list.exe
file authsrv-delete.exe
file ..\scripts\authsrv.pl
file ..\scripts\authsrv-dump.pl
file ..\scripts\authsrv-load.pl

IfFileExists C:\authsrv\*.* +3 0
  CreateDirectory C:\authsrv
  CreateDirectory C:\authsrv\keys

IfFileExists C:\authsrv\keys\*.* +2 0
  CreateDirectory C:\authsrv\keys

/* create a dummy host key, really need to use md5 plugin or something
 * appropriate, but since no security anyway, does it really matter? */
IfFileExists C:\authsrv\host-key +4 0
  fileOpen $0 "C:\authsrv\host-key" w
  fileWrite $0 "dummy-host-key-lkhasd23976235blygi86234jksgdf"
  fileClose $0

# define uninstaller name
writeUninstaller $INSTDIR\uninstall-authsrv.exe
 
# default section end
sectionEnd
 
# create a section to define what the uninstaller does.
# the section will always be named "Uninstall"
section "Uninstall"
 
# Always delete uninstaller first
delete $INSTDIR\uninstall-authsrv.exe
 
# now delete installed file
delete $INSTDIR\authsrv-decrypt.exe
delete $INSTDIR\authsrv-encrypt.exe
delete $INSTDIR\authsrv-list.exe
delete $INSTDIR\authsrv-delete.exe
 
sectionEnd

