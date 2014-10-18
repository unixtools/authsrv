# define installer name
name "AuthSrv"
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
file authsrv-raw-decrypt.exe
file authsrv-raw-encrypt.exe
file authsrv-list.exe
file authsrv-delete.exe
file ..\scripts\authsrv.pl
file ..\scripts\authsrv-dump.pl
file ..\scripts\authsrv-load.pl
file authsrv.bat
file authsrv-dump.bat
file authsrv-load.bat

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

WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AuthSrv" \
                 "DisplayName" "AuthSrv -- password stashing facility"

WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AuthSrv" \
                 "UninstallString" "$\"$INSTDIR\uninstall-authsrv.exe$\""

WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AuthSrv" \
                 "QuietUninstallString" "$\"$INSTDIR\uninstall-authsrv.exe$\" /S"


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
delete $INSTDIR\authsrv-raw-decrypt.exe
delete $INSTDIR\authsrv-raw-encrypt.exe
delete $INSTDIR\authsrv-list.exe
delete $INSTDIR\authsrv-delete.exe
delete ..\scripts\authsrv.pl
delete ..\scripts\authsrv-dump.pl
delete ..\scripts\authsrv-load.pl
delete authsrv.bat
delete authsrv-dump.bat
delete authsrv-load.bat

# Not deleting the host-key and/or password stashes intentionally, though that would be good to consider later


DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AuthSrv"
 
sectionEnd

