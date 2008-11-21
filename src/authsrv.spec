
Summary: AuthSrv Tool
Name: authsrv
Version: 1.5
Release: 1
License: Distributable
Group: System Environment/Base
BuildArch: i386
AutoReqProv: no

Packager: Nathan Neulinger <nneul@neulinger.org>

Source: authsrv.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

%description
This contains the authsrv utility.

%prep
%setup -c -q -n authsrv

%build
cd authsrv
make DATADIR=%{_datadir}/authsrv BINDIR=%{_bindir}

%install
cd authsrv
umask 077
mkdir -p $RPM_BUILD_ROOT/%{_datadir}/authsrv/keys
umask 022
mkdir -p $RPM_BUILD_ROOT/%{_bindir}
cp encrypt $RPM_BUILD_ROOT/%{_bindir}/authsrv-encrypt
cp decrypt $RPM_BUILD_ROOT/%{_bindir}/authsrv-decrypt
cp delete $RPM_BUILD_ROOT/%{_bindir}/authsrv-delete
cp list $RPM_BUILD_ROOT/%{_bindir}/authsrv-list
cp auth $RPM_BUILD_ROOT/%{_bindir}/authsrv-auth
cp authsrv.pl $RPM_BUILD_ROOT/%{_bindir}/authsrv
cp authsrv-dump.pl $RPM_BUILD_ROOT/%{_bindir}/authsrv-dump
cp authsrv-load.pl $RPM_BUILD_ROOT/%{_bindir}/authsrv-load

%post
umask 077
if [ ! -e %{_datadir}/authsrv/host-key ]; then
	head -64c /dev/urandom > %{_datadir}/authsrv/host-key
fi
# fix any previous permissions issues
chmod 400 %{_datadir}/authsrv/host-key
chown -R root:root %{_datadir}/authsrv
chmod -R go-rwx %{_datadir}/authsrv

%clean
%{__rm} -rf %{buildroot}

%files
%attr(0755, root, root) %{_bindir}/authsrv

%attr(0755, root, root) %{_bindir}/authsrv-dump
%attr(0755, root, root) %{_bindir}/authsrv-load

%attr(4755, root, root) %{_bindir}/authsrv-auth
%attr(4755, root, root) %{_bindir}/authsrv-decrypt
%attr(4755, root, root) %{_bindir}/authsrv-delete
%attr(4755, root, root) %{_bindir}/authsrv-encrypt
%attr(4755, root, root) %{_bindir}/authsrv-list

%attr(0700, root, root) %{_datadir}/authsrv
#%attr(0700, root, root) %{_datadir}/authsrv/keys

%changelog
