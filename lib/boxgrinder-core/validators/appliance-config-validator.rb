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

require 'boxgrinder-core/validators/errors'
require 'boxgrinder-core/defaults'

module BoxGrinder
  class ApplianceConfigValidator
    def initialize( appliance_config, options = {} )
      @appliance_config = appliance_config
      @options          = options
    end

    def validate
      check_for_missing_field( 'name' )
      check_for_missing_field( 'summary' )

      validate_os
      validate_hardware
      validate_repos
    end

    protected

    def check_for_missing_field( name )
      raise ApplianceValidationError, "Missing field: appliance definition file should have field '#{name}'" if eval("@appliance_config.#{name}").nil?
    end

    def validate_os
      raise "No operating system plugins installed. Install one or more operating system plugin. See http://community.jboss.org/docs/DOC-15081 and http://community.jboss.org/docs/DOC-15214 for more info" if PluginManager.instance.plugins[:os].empty?

      os_plugin = PluginManager.instance.plugins[:os][@appliance_config.os.name.to_sym]

      raise ApplianceValidationError, "No operating system selected" if @appliance_config.os.name.nil?
      raise ApplianceValidationError, "Not supported operating system selected: #{@appliance_config.os.name}. Make sure you have installed right operating system plugin, see http://community.jboss.org/docs/DOC-15214. Supported OSes are: #{PluginManager.instance.plugins[:os].keys.join(", ")}" if os_plugin.nil?
      raise ApplianceValidationError, "Not supported operating system version selected: #{@appliance_config.os.version}. Supported versions are: #{os_plugin[:versions].join(", ")}" unless @appliance_config.os.version.nil? or os_plugin[:versions].include?( @appliance_config.os.version )
    end

    def validate_hardware
      raise ApplianceValidationError, "Not valid CPU amount: Too many or too less CPU's: '#{@appliance_config.hardware.cpus}'. Please choose from 1-4. Please correct your appliance definition file, thanks." unless @appliance_config.hardware.cpus >= 1 and @appliance_config.hardware.cpus <= 4
      raise ApplianceValidationError, "Not valid memory amount: '#{@appliance_config.hardware.memory}' is wrong value. Please correct your appliance definition file" if @appliance_config.hardware.memory =~ /\d/
      raise ApplianceValidationError, "Not valid memory amount: '#{@appliance_config.hardware.memory}' is not allowed here. Memory should be multiplicity of 64. Please correct your appliance definition file" if (@appliance_config.hardware.memory.to_i % 64 > 0)

      raise ApplianceValidationError, "No partitions found. Please correct your appliance definition file" if @appliance_config.hardware.partitions.size == 0
    end

    def validate_repos
      return if @appliance_config.repos.size == 0

      @appliance_config.repos.each do |repo|
        raise ApplianceValidationError, "Not valid repo format: '#{repo}' is wrong value. Please correct your appliance definition file, thanks." unless repo.class.eql?(Hash)
        raise ApplianceValidationError, "Not valid repo format: Please specify name for repository. Please correct your appliance definition file, thanks." unless repo.keys.include?('name')
        raise ApplianceValidationError, "Not valid repo format: There is no 'mirrorlist' or 'baseurl' specified for '#{repo['name']}' repository. Please correct your appliance definition file, thanks." unless repo.keys.include?('mirrorlist') or repo.keys.include?('baseurl')
      end
    end
  end
end
