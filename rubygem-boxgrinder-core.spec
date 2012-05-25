%global gem_name boxgrinder-core

%{!?gem_dir: %global gem_dir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)}
%{!?gem_instdir: %global gem_instdir %{gem_dir}/gems/%{gem_name}-%{version}}

%if 0%{?fedora} >= 17
%global rubyabi 1.9.1
%else
%global rubyabi 1.8
%endif

Summary:     Core library for BoxGrinder
Name:        rubygem-%{gem_name}
Version:     0.3.12
Release:     1%{?dist}
Group:       Development/Languages
License:     LGPLv3+
URL:         http://boxgrinder.org/
Source0:     http://rubygems.org/gems/%{gem_name}-%{version}.gem

Requires: ruby(abi) = %{rubyabi}
Requires: rubygem(open4)
Requires: rubygem(hashery)
Requires: rubygem(kwalify)
Requires: rubygem(term-ansicolor)

BuildRequires: rubygem(rake)
BuildRequires: rubygem(open4)
BuildRequires: rubygem(hashery)
BuildRequires: rubygem(echoe)
BuildRequires: rubygem(kwalify)
BuildRequires: rubygems-devel
BuildRequires: rubygem(term-ansicolor)

%if 0%{?fedora} >= 17
BuildRequires: rubygem(rspec)
%else
BuildRequires: rubygem(rspec-core)
%endif

BuildArch: noarch
Provides: rubygem(%{gem_name}) = %{version}

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
mkdir -p .%{gem_dir}
gem install --local --install-dir .%{gem_dir} \
            --force --rdoc %{SOURCE0}

%build

%install
mkdir -p %{buildroot}%{gem_dir}
cp -a .%{gem_dir}/* %{buildroot}%{gem_dir}/

%check
pushd .%{gem_instdir}
rspec -r spec_helper -r boxgrinder-core spec/**/*-spec.rb
popd

%files
%defattr(-, root, root, -)
%dir %{gem_instdir}
%{gem_libdir}
%doc %{gem_instdir}/CHANGELOG
%doc %{gem_instdir}/LICENSE
%doc %{gem_instdir}/README
%doc %{gem_instdir}/Manifest
%{gem_cache}
%{gem_spec}

%files doc
%defattr(-, root, root, -)
%{gem_instdir}/spec
%{gem_instdir}/Rakefile
%{gem_instdir}/rubygem-%{gem_name}.spec
%{gem_instdir}/%{gem_name}.gemspec
%{gem_docdir}

%changelog
* Thu May 24 2012 Marc Savy <msavy@redhat.com> - 0.3.12
- Upstream release: 0.3.11
- Support for printing coloured terminal output 

* Wed Feb 29 2012 Marc Savy <msavy@redhat.com> - 0.3.11
- Upstream release: 0.3.11
- [BGBUILD-346] Confirm Ruby 1.9.3 support
- [BGBUILD-348] Simplecov coverage testing for Ruby >=1.9

* Thu Dec 1 2011 Marc Savy <msavy@redhat.com> - 0.3.10
- Upstream release: 0.3.10
- [BGBUILD-324] Add wildcard to packages schema
- [BGBUILD-320] Support variable substitution in any string value field of appliance definition
- [BGBUILD-327] Resolve appliance definition variables in ENV if they are not defined

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
