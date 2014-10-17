
Summary: AuthSrv Tool
Name: authsrv
Version: 3.0
Release: 1
License: Distributable
Group: System Environment/Base
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
%{__rm} -rf %{buildroot}
cd authsrv/unix
make DATADIR=%{buildroot}%{_datadir}/authsrv BINDIR=%{buildroot}%{_bindir} install
umask 077
mkdir -p %{buildroot}%{_datadir}/authsrv/keys
umask 022

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
%defattr(-, root, root, 0755)
%attr(0755, root, root) %{_bindir}/authsrv

%attr(0755, root, root) %{_bindir}/authsrv-dump
%attr(0755, root, root) %{_bindir}/authsrv-load

%attr(4755, root, root) %{_bindir}/authsrv-auth
%attr(4755, root, root) %{_bindir}/authsrv-decrypt
%attr(4755, root, root) %{_bindir}/authsrv-decrypt-raw
%attr(4755, root, root) %{_bindir}/authsrv-delete
%attr(4755, root, root) %{_bindir}/authsrv-encrypt
%attr(4755, root, root) %{_bindir}/authsrv-encrypt-raw
%attr(4755, root, root) %{_bindir}/authsrv-list

%attr(0700, root, root) %{_datadir}/authsrv

%changelog
