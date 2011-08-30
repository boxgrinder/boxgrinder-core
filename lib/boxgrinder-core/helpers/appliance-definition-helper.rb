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

require 'boxgrinder-core/helpers/log-helper'
require 'boxgrinder-core/models/appliance-config'
require 'boxgrinder-core/appliance-parser'

module BoxGrinder
  class ApplianceDefinitionHelper
    def initialize(options = {})
      @log = options[:log] || LogHelper.new
      @appliance_configs = []
      @appliance_parser = ApplianceParser.new(:log => @log)
    end

    attr_reader :appliance_configs
    attr_reader :appliance_parser

    # Reads definition provided as string. This string can be a YAML document. In this case
    # definition is parsed and an ApplianceConfig object is returned. In other cases it tries to search
    # for a file with provided name.
    def read_definitions(definition, content_type = nil)
      @appliance_parser.load_schemas
      if File.exists?(definition)
        definition_file_extension = File.extname(definition)

        appliance_config =
            case definition_file_extension
              when '.appl', '.yml', '.yaml'
                parse_yaml(@appliance_parser.parse_definition(definition))
              else
                unless content_type.nil?
                  case content_type
                    when 'application/x-yaml', 'text/yaml'
                      parse_yaml(@appliance_parser.parse_definition(definition))
                  end
                end
            end

        return if appliance_config.nil?

        @appliance_configs << appliance_config
        appliances = []

        @appliance_configs.each { |config| appliances << config.name }

        appliance_config.appliances.reverse.each do |appliance_name|
          read_definitions("#{File.dirname(definition)}/#{appliance_name}#{definition_file_extension}") unless appliances.include?(appliance_name)
        end unless appliance_config.appliances.nil? or !appliance_config.appliances.is_a?(Array)
      else
        # Assuming that the definition is provided as string
        @appliance_configs << parse_yaml(@appliance_parser.parse_definition(definition, false))
      end
    end

    # TODO this needs to be rewritten - using kwalify it could be possible to instantiate document structure as objects[, or opencascade hash?]
    def parse_yaml(definition)
      return definition if definition.is_a?(ApplianceConfig)
      raise "Provided definition is not a Hash." unless definition.is_a?(Hash)

      appliance_config = ApplianceConfig.new

      appliance_config.name = definition['name'] unless definition['name'].nil?
      appliance_config.summary = definition['summary'] unless definition['summary'].nil?

      definition['variables'].each { |key, value| appliance_config.variables[key] = value } unless definition['variables'].nil?

      @log.debug "Adding packages to appliance..."

      appliance_config.packages = definition['packages'] unless definition['packages'].nil?

      @log.debug "#{appliance_config.packages.size} package(s) added to appliance." if appliance_config.packages

      appliance_config.appliances = definition['appliances'] unless definition['appliances'].nil?
      appliance_config.repos = definition['repos'] unless definition['repos'].nil?

      appliance_config.version = definition['version'] unless definition['version'].nil?
      appliance_config.release = definition['release'] unless definition['release'].nil?

      unless definition['default_repos'].nil?
        appliance_config.default_repos = definition['default_repos']
        raise "default_repos should be set to true or false" unless appliance_config.default_repos.is_a?(TrueClass) or appliance_config.default_repos.is_a?(FalseClass)
      end

      unless definition['os'].nil?
        appliance_config.os.name = definition['os']['name'] unless definition['os']['name'].nil?
        appliance_config.os.version = definition['os']['version'] unless definition['os']['version'].nil?
        appliance_config.os.password = definition['os']['password'] unless definition['os']['password'].nil?
        appliance_config.os.pae = definition['os']['pae'] unless definition['os']['pae'].nil?
      end

      unless definition['hardware'].nil?
        appliance_config.hardware.arch = definition['hardware']['arch'] unless definition['hardware']['arch'].nil?
        appliance_config.hardware.cpus = definition['hardware']['cpus'] unless definition['hardware']['cpus'].nil?
        appliance_config.hardware.memory = definition['hardware']['memory'] unless definition['hardware']['memory'].nil?
        appliance_config.hardware.network = definition['hardware']['network'] unless definition['hardware']['network'].nil?

        unless definition['hardware']['partitions'].nil?
          definition['hardware']['partitions'].each do |key, part|
            appliance_config.hardware.partitions[key] = part
          end if definition['hardware']['partitions'].is_a?(Hash)
        end
      end

      definition['files'].each { |key, value| appliance_config.files[key] = value } unless definition['files'].nil?
      definition['post'].each { |key, value| appliance_config.post[key] = value } unless definition['post'].nil?

      appliance_config
    end
  end
end
