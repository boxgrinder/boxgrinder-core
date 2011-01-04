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

module BoxGrinder
  # here are global variables
  SUPPORTED_ARCHES        = ["i386", "x86_64"]

  APPLIANCE_DEFAULTS      = {
      :os       => {
          :password => "boxgrinder"
      },
      :hardware => {
          :partitions => {"/" => { 'size' => 1 }},
          :memory     => 256,
          :network    => "NAT",
          :cpus       => 1
      }
  }

  SUPPORTED_DESKTOP_TYPES = ["gnome"]

  DEFAULT_LOCATION        = {
      :log => 'log/boxgrinder.log'
  }

  DEFAULT_HELP_TEXT       = {
      :general => "See documentation: http://community.jboss.org/docs/DOC-14358."
  }

  DEFAULT_PROJECT_CONFIG  = {
      :name           => 'BoxGrinder',
      :dir_build      => 'build',
      #:topdir            => "#{self.} build/topdir",
      :dir_src_cache  => '/var/cache/boxgrinder/sources-cache',
      :dir_rpms_cache => '/var/cache/boxgrinder/rpms-cache',
      :dir_specs      => 'specs',
      :dir_appliances => 'appliances',
      :dir_src        => 'src',
      :dir_kickstarts => 'kickstarts'
  }
end
