%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gemname boxgrinder-core
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}
%global rubyabi 1.8

Summary: Core library for BoxGrinder
Name: rubygem-%{gemname}
Version: 0.2.0
Release: 1%{?dist}
Group: Development/Languages
License: LGPLv3+
URL: http://www.jboss.org/boxgrinder
Source0: http://rubygems.org/gems/%{gemname}-%{version}.gem
BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

Requires: ruby(abi) = %{rubyabi}
Requires: rubygem(open4)
Requires: rubygem(hashery)

BuildRequires: rubygem(rake)
BuildRequires: rubygem(rspec)
BuildRequires: rubygem(open4)
BuildRequires: rubygem(hashery)
BuildRequires: rubygem(echoe)

BuildArch: noarch
Provides: rubygem(%{gemname}) = %{version}

%description
Core library containing files required by BoxGrinder family of projects

%package doc
Summary: Documentation for %{name}
Group: Documentation
Requires:%{name} = %{version}-%{release}

%description doc
Documentation for %{name}

%prep
%setup -q -c -T
mkdir -p .%{gemdir}
gem install --local --install-dir .%{gemdir} \
            --force --rdoc %{SOURCE0}

%build

%install
mkdir -p %{buildroot}%{gemdir}
cp -a .%{gemdir}/* %{buildroot}%{gemdir}/

%check
pushd .%{geminstdir}
rake spec
popd

%files
%defattr(-, root, root, -)
%dir %{geminstdir}
%{geminstdir}/lib
%doc %{geminstdir}/CHANGELOG
%doc %{geminstdir}/LICENSE
%doc %{geminstdir}/README
%doc %{geminstdir}/Manifest
%{gemdir}/cache/%{gemname}-%{version}.gem
%{gemdir}/specifications/%{gemname}-%{version}.gemspec

%files doc
%defattr(-, root, root, -)
%{geminstdir}/spec
%{geminstdir}/Rakefile
%{geminstdir}/rubygem-%{gemname}.spec
%{geminstdir}/%{gemname}.gemspec
%{gemdir}/doc/%{gemname}-%{version}

%changelog
* Tue Jan 04 2011  <mgoldman@redhat.com> - 0.2.0-1
- Upstream release: 0.2.0
- Added BuildRoot tag to build for EPEL 5
- [BGBUILD-79] Allow to use BoxGrinder Build as a library
- [BGBUILD-127] Use appliance definition object instead of a file when using BG as a library
- [BGBUILD-68] Global .boxgrinder/config or rc style file for config
- [BGBUILD-93] Add Red Hat Enterprise Linux 6 support
- [BGBUILD-133] Support a consolidated configuration file
- [BGBUILD-101] Don't use 'includes' subsection when specifying packages
- [BGBUILD-60] Post section merging pattern for appliances depending on the same appliance
- [BGBUILD-151] Overriding hardware partitions via inclusion in Appliance Definition File causes build failure

* Tue Dec 21 2010  <mgoldman@redhat.com> - 0.1.6-1
- Updated to upstream version: 0.1.6
- [BGBUILD-100] Enable boxgrinder_build to create a Fedora image with encrypted partition(s)

* Sun Dec 12 2010  <mgoldman@redhat.com> - 0.1.5-1
- Updated to upstream version: 0.1.5
- [BGBUILD-73] Add support for kickstart files

* Thu Dec 02 2010  <mgoldman@redhat.com> - 0.1.4-1
- Updated to new upstream release: 0.1.4

* Wed Nov 17 2010  <mgoldman@redhat.com> - 0.1.3-3
- Added: BuildRequires: rubygem(echoe)
- Changed the way Gem is installed and tests are exeuted

* Mon Nov 15 2010  <mgoldman@redhat.com> - 0.1.3-2
- Removing unecessary Requires: rubygems

* Mon Nov 15 2010  <mgoldman@redhat.com> - 0.1.3-1
- Removed BuildRoot tag
- Adjusted Requires and BuildRequires
- Different approach for testing
- [BGBUILD-98] Use hashery gem

* Tue Nov 09 2010  <mgoldman@redhat.com> - 0.1.2-1
- [BGBUILD-87] Set default filesystem to ext4 for Fedora 13+
- [BGBUILD-65] Allow to specify own repos overriding default repos provided for selected OS

* Tue Nov 09 2010  <mgoldman@redhat.com> - 0.1.1-2
- [BGBUILD-85] Adjust BoxGrinder spec files for review
- Added 'check' section that executes tests

* Mon Oct 18 2010  <mgoldman@redhat.com> - 0.1.1-1
- Initial package
