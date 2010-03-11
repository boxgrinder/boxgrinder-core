# JBoss, Home of Professional Open Source
# Copyright 2009, Red Hat Middleware LLC, and individual contributors
# by the @authors tag. See the copyright.txt in the distribution for a
# full listing of individual contributors.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of
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

require 'boxgrinder/helpers/log-helper'
require 'boxgrinder/helpers/exec-helper'

module BoxGrinder
  # here are global variables
  SUPPORTED_ARCHES = [ "i386", "x86_64" ]
  SUPPORTED_OSES = {
          "fedora" => [ "12", "11", "rawhide" ]
  }

  LATEST_STABLE_RELEASES = {
          "fedora" => "12",
          "rhel" => "5"
  }

  DEVELOPMENT_RELEASES = {
          "fedora" => "rawhide"
  }

  APPLIANCE_DEFAULTS = {
          :os => {
                  :name => "fedora",
                  :version => LATEST_STABLE_RELEASES['fedora'],
                  :password => "boxgrinder"
          },
          :hardware => {
                  :partition => 1,
                  :memory => 256,
                  :network => "NAT",
                  :cpus => 1
          }
  }

  SUPPORTED_DESKTOP_TYPES = [ "gnome" ]

  # you can use #ARCH# variable to specify build arch
  REPOS = {
          "fedora" => {
                  "12" => {
                          "base" => {
                                  "mirrorlist" => "http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-12&arch=#ARCH#"
                          },
                          "updates" => {
                                  "mirrorlist" => "http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f12&arch=#ARCH#"
                          }
                  },
                  "11" => {
                          "base" => {
                                  "mirrorlist" => "http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-11&arch=#ARCH#"
                          },
                          "updates" => {
                                  "mirrorlist" => "http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f11&arch=#ARCH#"
                          }
                  },
                  "rawhide" => {
                          "base" => {
                                  "mirrorlist" => "http://mirrors.fedoraproject.org/mirrorlist?repo=rawhide&arch=#ARCH#"
                          }
                  }
          }
  }

  DEFAULT_LOCATION = {
          :log => 'log/boxgridner.log'
  }

  DEFAULT_HELP_TEXT = {
          :general => "See documentation: http://community.jboss.org/docs/DOC-14358."
  }

  DEFAULT_PROJECT_CONFIG = {
          :name           => 'BoxGrinder',
          :version        => '1.0.0.Beta2',
          :release        => 'SNAPSHOT',
          :dir_build      => 'build',
          #:topdir            => "#{self.} build/topdir",
          :dir_src_cache  => 'sources-cache',
          :dir_rpms_cache => 'rpms-cache',
          :dir_specs      => 'specs',
          :dir_appliances => 'appliances',
          :dir_src        => 'src',
          :dir_kickstarts => 'kickstarts'
  }

  AWS_DEFAULTS = {
          :bucket_prefix  => "#{DEFAULT_PROJECT_CONFIG[:name].downcase}/#{DEFAULT_PROJECT_CONFIG[:version]}-#{DEFAULT_PROJECT_CONFIG[:release]}",
          :kernel_id      => { "i386" => "aki-a71cf9ce", "x86_64" => "aki-b51cf9dc" }, # EU: :kernel_id => { "i386" => "aki-61022915", "x86_64" => "aki-6d022919" },
          :ramdisk_id     => { "i386" => "ari-a51cf9cc", "x86_64" => "ari-b31cf9da" }, # EU: :ramdisk_id => { "i386" => "ari-63022917", "x86_64" => "ari-37022943" },
          :kernel_rpm     => { "i386" => "http://repo.oddthesis.org/packages/other/kernel-xen-2.6.21.7-2.fc8.i686.rpm", "x86_64" => "http://repo.oddthesis.org/packages/other/kernel-xen-2.6.21.7-2.fc8.x86_64.rpm" },
          :modules        => { "i386" => "http://s3.amazonaws.com/ec2-downloads/ec2-modules-2.6.21.7-2.ec2.v1.2.fc8xen-i686.tgz", "x86_64" => "http://s3.amazonaws.com/ec2-downloads/ec2-modules-2.6.21.7-2.ec2.v1.2.fc8xen-x86_64.tgz" }
  }
end
