%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gemname boxgrinder-core
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}
%global rubyabi 1.8

Summary: Core library for BoxGrinder
Name: rubygem-%{gemname}
Version: 0.1.3
Release: 1%{?dist}
Group: Development/Languages
License: LGPLv3+
URL: http://www.jboss.org/boxgrinder
Source0: http://rubygems.org/gems/%{gemname}-%{version}.gem

Requires: ruby(abi) = %{rubyabi}
Requires: rubygems
Requires: rubygem(open4)
Requires: rubygem(hashery)

BuildRequires: rubygem(rake)
BuildRequires: rubygem(rspec)
BuildRequires: rubygem(open4)
BuildRequires: rubygem(hashery)

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

%build

%install
rm -rf %{buildroot}
rm -rf %{_builddir}%{gemdir}

mkdir -p %{_builddir}%{gemdir}
gem install --local --install-dir %{_builddir}%{gemdir} \
            --force --rdoc %{SOURCE0}
mkdir -p %{buildroot}/%{gemdir}
cp -r %{_builddir}%{gemdir}/* %{buildroot}/%{gemdir}

%check
pushd %{_builddir}/%{geminstdir}
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
