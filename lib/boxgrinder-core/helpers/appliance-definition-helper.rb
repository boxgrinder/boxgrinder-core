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
                @appliance_parser.parse_definition(definition)
              else
                unless content_type.nil?
                  case content_type
                    when 'application/x-yaml', 'text/yaml'
                      @appliance_parser.parse_definition(definition)
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
        @appliance_configs << @appliance_parser.parse_definition(definition, false)
      end
    end
  end
end
