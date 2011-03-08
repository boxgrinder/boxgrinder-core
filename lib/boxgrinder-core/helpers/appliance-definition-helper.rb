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

require 'boxgrinder-core/models/appliance-config'
require 'yaml'

module BoxGrinder
  class ApplianceDefinitionHelper
    def initialize(options = {})
      @log = options[:log] || Logger.new(STDOUT)
      @appliance_configs = []
    end

    attr_reader :appliance_configs

    # Reads definition provided as string. This string can be a YAML document. In this case
    # definition is parsed and an ApplianceConfig object is returned. In other cases it tries to search
    # for a file with provided name.
    def read_definitions(definition, content_type = nil)
      if File.exists?(definition)
        @log.debug "Reading definition from '#{definition}' file..."

        definition_file_extension = File.extname(definition)

        appliance_config =
            case definition_file_extension
              when '.appl', '.yml', '.yaml'
                read_yaml_file(definition)
              when '.xml'
                read_xml_file(definition)
              else
                unless content_type.nil?
                  case content_type
                    when 'application/x-yaml', 'text/yaml'
                      read_yaml_file(definition)
                    when 'application/xml', 'text/xml', 'application/x-xml'
                      read_xml_file(definition)
                  end
                end
            end

        raise 'Unsupported file format for appliance definition file.' if appliance_config.nil?

        @appliance_configs << appliance_config
        appliances = []

        @appliance_configs.each { |config| appliances << config.name }

        appliance_config.appliances.reverse.each do |appliance_name|
          read_definitions("#{File.dirname(definition)}/#{appliance_name}#{definition_file_extension}") unless appliances.include?(appliance_name)
        end unless appliance_config.appliances.nil? or !appliance_config.appliances.is_a?(Array)
      else
        @log.debug "Reading definition..."

        @appliance_configs << read_yaml(definition)
      end
    end

    def read_yaml(content)
      begin
        definition = YAML.load(content)
        raise "Not a valid YAML content." if definition.nil? or definition == false
      rescue
        raise "Provided definition could not be read."
      end

      parse_yaml(definition)
    end

    def read_yaml_file(file)
      begin
        definition = YAML.load_file(file)
        raise "Not a valid YAML file." if definition.nil? or definition == false
      rescue
        raise "File '#{file}' could not be read."
      end

      parse_yaml(definition)
    end

    # TODO this needs to be rewritten
    def parse_yaml(definition)
      return definition if definition.is_a?(ApplianceConfig)
      raise "Provided definition is not a Hash." unless definition.is_a?(Hash)

      appliance_config = ApplianceConfig.new

      appliance_config.name = definition['name'] unless definition['name'].nil?
      appliance_config.summary = definition['summary'] unless definition['summary'].nil?

      definition['variables'].each { |key, value| appliance_config.variables[key] = value } unless definition['variables'].nil?

      @log.debug "Adding packages to appliance..."

      unless definition['packages'].nil?
        if definition['packages'].is_a?(Array)
          # new format
          appliance_config.packages = definition['packages']
        elsif definition['packages'].is_a?(Hash)
          # legacy format
          @log.warn "BoxGrinder Build packages section format has been changed. Support for legacy format will be removed in the future. See http://boxgrinder.org/tutorials/appliance-definition/ for more information about current format."
          appliance_config.packages = definition['packages']['includes'] if definition['packages']['includes'].is_a?(Array)
          @log.warn "BoxGrinder Build no longer supports package exclusion, the following packages will not be explicitly excluded: #{definition['packages']['excludes'].join(", ")}." if definition['packages']['excludes'].is_a?(Array)
        else
          @log.warn "Unsupported format for packages section."
        end
      end

      @log.debug "#{appliance_config.packages.size} package(s) added to appliance."

      appliance_config.appliances = definition['appliances'] unless definition['appliances'].nil?
      appliance_config.repos = definition['repos'] unless definition['repos'].nil?

      appliance_config.version = definition['version'].to_s unless definition['version'].nil?
      appliance_config.release = definition['release'].to_s unless definition['release'].nil?

      unless definition['default_repos'].nil?
        appliance_config.default_repos = definition['default_repos']
        raise "default_repos should be set to true or false" unless appliance_config.default_repos.is_a?(TrueClass) or appliance_config.default_repos.is_a?(FalseClass)
      end

      unless definition['os'].nil?
        appliance_config.os.name = definition['os']['name'].to_s unless definition['os']['name'].nil?
        appliance_config.os.version = definition['os']['version'].to_s unless definition['os']['version'].nil?
        appliance_config.os.password = definition['os']['password'].to_s unless definition['os']['password'].nil?
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

      definition['post'].each { |key, value| appliance_config.post[key] = value } unless definition['post'].nil?

      appliance_config
    end

    def read_xml_file(file)
      raise "Reading XML files is not supported right now. File '#{file}' could not be read."
    end
  end
end
