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

require 'boxgrinder-core/models/config'
require 'boxgrinder-core/models/appliance-config'
require 'boxgrinder-core/helpers/appliance-config-helper'
require 'boxgrinder-core/helpers/appliance-helper'
require 'logger'

Logger.const_set(:TRACE, 0)
Logger.const_set(:DEBUG, 1)
Logger.const_set(:INFO, 2)
Logger.const_set(:WARN, 3)
Logger.const_set(:ERROR, 4)
Logger.const_set(:FATAL, 5)
Logger.const_set(:UNKNOWN, 6)

Logger::SEV_LABEL.insert(0, 'TRACE')

class Logger
  def trace?
    @level <= TRACE
  end

  def trace(progname = nil, &block)
    add(TRACE, nil, progname, &block)
  end
end

module RSpecConfigHelper
  RSPEC_BASE_LOCATION = "#{File.dirname(__FILE__)}"

  def generate_config( params = OpenStruct.new )
    config = BoxGrinder::Config.new

    # files
    config.files.base_vmdk  = params.base_vmdk      || "../../../src/base.vmdk"
    config.files.base_vmx   = params.base_vmx       || "../../../src/base.vmx"

    config
  end

  def generate_appliance_config( appliance_definition_file = "#{RSPEC_BASE_LOCATION}/src/appliances/full.appl" )
    appliance_configs, appliance_config = BoxGrinder::ApplianceHelper.new(:log => Logger.new('/dev/null')).read_definitions( appliance_definition_file )
    appliance_config_helper = BoxGrinder::ApplianceConfigHelper.new( appliance_configs )

    appliance_config_helper.merge(appliance_config.clone.init_arch).initialize_paths
  end

  def generate_appliance_config_gnome( os_version = "11" )
    appliance_config = BoxGrinder::ApplianceConfig.new("valid-appliance-gnome", (-1.size) == 8 ? "x86_64" : "i386", "fedora", os_version)

    appliance_config.disk_size = 2
    appliance_config.summary = "this is a summary"
    appliance_config.network_name = "NAT"
    appliance_config.vcpu = "1"
    appliance_config.mem_size = "1024"
    appliance_config.appliances = [ appliance_config.name ]

    appliance_config
  end
end
