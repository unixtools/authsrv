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

