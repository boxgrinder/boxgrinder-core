%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gemname boxgrinder-core
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}
%global rubyabi 1.8

Summary: Core library for BoxGrinder
Name: rubygem-%{gemname}
Version: 0.3.10
Release: 1%{?dist}
Group: Development/Languages
License: LGPLv3+
URL: http://boxgrinder.org/
Source0: http://rubygems.org/gems/%{gemname}-%{version}.gem

Requires: ruby(abi) = %{rubyabi}
Requires: rubygem(open4)
Requires: rubygem(hashery)
Requires: rubygem(kwalify)

BuildRequires: rubygem(rake)
BuildRequires: rubygem(open4)
BuildRequires: rubygem(hashery)
BuildRequires: rubygem(echoe)
BuildRequires: rubygem(kwalify)
# Use rspec-core until rspec are migrated to RSpec 2.x
BuildRequires: rubygem(rspec-core)

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
* Thu Dec 1 2011 Marc Savy <mgoldman@redhat.com> - 0.3.10
- Upstream release: 0.3.10
- [BGBUILD-324] Add wildcard to packages schema
- [BGBUILD-320] Support variable substitution in any string value field of appliance definition

* Fri Oct 14 2011 Marc Savy <msavy@redhat.com> - 0.3.9-1
- Upstream release: 0.3.9
- [BGBUILD-312] Discover which user to switch to after root dependent sections have been executed

* Wed Sep 7 2011 Marek Goldmann <mgoldman@redhat.com> - 0.3.8-1
- [BGBUILD-305] Incorrect version information in 0.9.6 schema causing validation errors

* Tue Aug 30 2011 Marek Goldmann <mgoldman@redhat.com> - 0.3.7-1
- Upstream release: 0.3.7
- [BGBUILD-276] Import files into appliance via appliance definition file (Files section)

* Tue Aug 23 2011 Marek Goldmann <mgoldman@redhat.com> - 0.3.6-1
- Upstream release: 0.3.6
- [BGBUILD-295] Remove arbitrary 4 CPU limit
- [BGBUILD-296] BG should refer to version and release when building new appliances

* Wed Jul 13 2011 Marek Goldmann <mgoldman@redhat.com> - 0.3.5-1
- Upstream release: 0.3.5
- [BGBUILD-273] Move to RSpec2
- [BGBUILD-275] default_repos setting is not included in schema and is not documented

* Tue Jun 28 2011 Marc Savy <msavy@redhat.com> - 0.3.4-1
- Upstream release: 0.3.4

* Tue Jun 28 2011 Marc Savy <msavy@redhat.com> - 0.3.3-1
- Upstream release: 0.3.3
- [BGBUILD-233] BoxGrinder Build fails to report a missing config file

* Tue May 10 2011 Marek Goldmann <mgoldman@redhat.com> - 0.3.2-1
- Upstream release: 0.3.2
- [BGBUILD-210] In Fedora 14 parameters are not being expanded, and cause early string truncation.
- [BGBUILD-208] Kickstart files not working with 0.9.1
- [BGBUILD-218] Incorrect error messages since revision of parser/validator

* Wed Apr 27 2011 Marek Goldmann <mgoldman@redhat.com> - 0.3.1-1
- Upstream release: 0.3.1
- [BGBUILD-164] Guestfs writes to /tmp/ by default, potentially filling the root filesystem
- [BGBUILD-97] some filesystems dont get unmounted on BG interruption
- [BGBUILD-155] Images built on Centos5.x (el5) for VirtualBox kernel panic (/dev/root missing)
- [BGBUILD-190] Allow to specify kernel variant (PAE or not) for Fedora OS
- [BGBUILD-192] Use IO.popen4 instead open4 gem on JRuby
- [BGBUILD-198] root password is not inherited
- [BGBUILD-156] Validate appliance definition files early and return meaningful error messages

* Sat Mar 05 2011 Marek Goldmann <mgoldman@redhat.com> - 0.3.0-1
- Upstream release: 0.3.0
- [BGBUILD-178] Remove sensitive data from logs
- [BGBUILD-168] Support deprecated package inclusion format in appliance definitions
- [BGBUILD-142] Backtraces make output unreadable - add option to enable them, and disable by default
- [BGBUILD-150] Cyclical inclusion dependencies in appliance definition files are not detected/handled
- [BGBUILD-79] Allow to use BoxGrinder Build as a library
- [BGBUILD-127] Use appliance definition object instead of a file when using BG as a library
- [BGBUILD-68] Global .boxgrinder/config or rc style file for config
- [BGBUILD-93] Add Red Hat Enterprise Linux 6 support
- [BGBUILD-133] Support a consolidated configuration file
- [BGBUILD-101] Don't use 'includes' subsection when specifying packages
- [BGBUILD-60] Post section merging pattern for appliances depending on the same appliance
- [BGBUILD-151] Overriding hardware partitions via inclusion in Appliance Definition File causes build failure
- [BGBUILD-100] Enable boxgrinder_build to create a Fedora image with encrypted partition(s)

* Sun Dec 12 2010 Marek Goldmann <mgoldman@redhat.com> - 0.1.5-1
- Updated to upstream version: 0.1.5
- [BGBUILD-73] Add support for kickstart files

* Thu Dec 02 2010 Marek Goldmann <mgoldman@redhat.com> - 0.1.4-1
- Updated to new upstream release: 0.1.4

* Wed Nov 17 2010 Marek Goldmann <mgoldman@redhat.com> - 0.1.3-3
- Added: BuildRequires: rubygem(echoe)
- Changed the way Gem is installed and tests are exeuted

* Mon Nov 15 2010 Marek Goldmann <mgoldman@redhat.com> - 0.1.3-2
- Removing unecessary Requires: rubygems

* Mon Nov 15 2010 Marek Goldmann <mgoldman@redhat.com> - 0.1.3-1
- Removed BuildRoot tag
- Adjusted Requires and BuildRequires
- Different approach for testing
- [BGBUILD-98] Use hashery gem

* Tue Nov 09 2010 Marek Goldmann <mgoldman@redhat.com> - 0.1.2-1
- [BGBUILD-87] Set default filesystem to ext4 for Fedora 13+
- [BGBUILD-65] Allow to specify own repos overriding default repos provided for selected OS

* Tue Nov 09 2010 Marek Goldmann <mgoldman@redhat.com> - 0.1.1-2
- [BGBUILD-85] Adjust BoxGrinder spec files for review
- Added 'check' section that executes tests

* Mon Oct 18 2010 Marek Goldmann <mgoldman@redhat.com> - 0.1.1-1
- Initial package
