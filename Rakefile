#
# Copyright 2010 Red Hat, Inc.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 3 of
# the License, or (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this software; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.

require 'rubygems'
require 'spec/rake/spectask'
require 'echoe'

Echoe.new("boxgrinder-core") do |p|
  p.project     = "BoxGrinder"
  p.author      = "Marek Goldmann"
  p.summary     = "Core library for BoxGrinder"
  p.url         = "http://www.jboss.org/boxgrinder"
  p.email       = "info@boxgrinder.org"
  p.runtime_dependencies = ['open4 >=1.0.0']
end

desc "Run all tests"
Spec::Rake::SpecTask.new('spec') do |t|
  t.rcov = false
  t.spec_files = FileList["spec/**/*-spec.rb"]
  t.spec_opts = ['--colour', '--format', 'specdoc', '-b']
  t.verbose = true
end

desc "Run all tests and generate code coverage report"
Spec::Rake::SpecTask.new('spec:coverage') do |t|
  t.spec_files = FileList["spec/**/*-spec.rb"]
  t.spec_opts = ['--colour', '--format', 'html:pkg/rspec_report.html', '-b']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec,teamcity/*,/usr/lib/ruby/,.gem/ruby,/boxgrinder-build/,/gems/']
  t.verbose = true
end

topdir = "#{Dir.pwd}/pkg/rpmbuild"
directory "#{topdir}/SOURCES"

task 'gem:copy' => [:gem, 'rpm:topdir'] do
  Dir["**/pkg/*.gem"].each { |gem| FileUtils.cp(gem, "#{topdir}/SOURCES", :verbose => true) }
end

task 'rpm:topdir' do
  FileUtils.mkdir_p(["#{topdir}/SOURCES", "#{topdir}/RPMS", "#{topdir}/BUILD", "#{topdir}/SPECS", "#{topdir}/SRPMS"], :verbose => true)
end

desc "Create RPM"
task 'rpm' => ['gem:copy'] do
  Dir["**/rubygem-*.spec"].each do |spec|
    puts `rpmbuild --define '_topdir #{topdir}' -ba #{spec}`
    exit 1 unless $? == 0
  end
end

desc "Install RPM"
task 'rpm:install' => ['rpm'] do
  puts "sudo yum -y remove rubygem-boxgrinder-core"
  system "sudo yum -y remove rubygem-boxgrinder-core"
  exit 1 unless $? == 0

  puts "sudo yum -y --nogpgcheck localinstall #{topdir}/RPMS/noarch/*.rpm"
  system "sudo yum -y --nogpgcheck localinstall #{topdir}/RPMS/noarch/*.rpm"
  exit 1 unless $? == 0
end