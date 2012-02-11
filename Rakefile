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
require 'rspec/core/rake_task'
require 'echoe'

Echoe.new("boxgrinder-core") do |p|
  p.project = "BoxGrinder"
  p.author = "Marek Goldmann"
  p.summary = "Core library for BoxGrinder"
  p.url = "http://boxgrinder.org"
  p.email = "info@boxgrinder.org"
  p.runtime_dependencies = ['hashery >=1.3.0', 'kwalify >=0.7.2']
  p.runtime_dependencies << 'open4 >=1.0.0' unless RUBY_PLATFORM =~ /java/
end

RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern = ["spec/**/*-spec.rb"]
  t.rspec_opts = ['-r', 'boxgrinder-core', '--colour', '--format', 'doc', '-b']
  t.verbose = true
end

def coverage18(t)
  require 'rcov'
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec,teamcity/*,/usr/lib/ruby/,.gem/ruby,/boxgrinder-build/,/gems/']
end

RSpec::Core::RakeTask.new('spec:coverage') do |t|  
  t.pattern = "spec/**/*-spec.rb"
  t.rspec_opts = ['-r spec_helper', '-r boxgrinder-core', '--colour', 
    '--format', 'html', '--out', 'pkg/rspec_report.html', '-b']
  t.verbose = true  

  if RUBY_VERSION =~ /^1.8/
    coverage18(t) 
  else
    ENV['COVERAGE'] = 'true'
  end
end
