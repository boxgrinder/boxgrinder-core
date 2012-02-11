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

require 'kwalify'
require 'boxgrinder-core/helpers/appliance-transformation-helper'
require 'boxgrinder-core/helpers/log-helper'
require 'boxgrinder-core/appliance-validator'
require 'boxgrinder-core/errors'

module BoxGrinder
  class ApplianceParser
    def initialize(options = {})
      @log = options[:log] || LogHelper.new
      @schemas = {}
    end

    def load_schemas
      Dir.glob("#{File.dirname(__FILE__)}/schemas/{*.yaml,*.yml}").each do |f|
        # DON'T use Kwalify::Yaml here!
        # This will not treat '#' sign in schema files correctly
        schema = YAML.load_file(f)
        @schemas[schema['version']] = schema
      end
    end

    def parse_definition(appliance_definition, file = true)
      if file
        @log.info "Validating appliance definition from #{appliance_definition} file..."
        appliance_definition = File.read(appliance_definition)
      else
        @log.info "Validating appliance definition from string..."
      end

      failures = {}
      schema_versions = @schemas.keys.sort.reverse

      schema_versions.each do |schema_version|
        @log.debug "Parsing definition using schema version #{schema_version}."
        @schemas[schema_version].delete('version')
        appliance_config, errors = parse(@schemas[schema_version], appliance_definition)

        if errors.empty?
          @log.info "Appliance definition is valid."
          return ApplianceTransformationHelper.new(schema_versions.first, :log => @log).transform(appliance_config, schema_version)
        end

        failures[schema_version] = errors
      end

      # If all schemas fail then we assume they are using the latest schema..
      failures[schema_versions.first].each do |error|
        @log.error "Error: [line #{error.linenum}, col #{error.column}] [#{error.path}] #{error.message}"
      end

      raise ApplianceValidationError, "The appliance definition was invalid according to schema #{schema_versions.first}. See log for details."
    end

    def parse(schema_document, appliance_definition)
      validator = ApplianceValidator.new(schema_document)
      parser = Kwalify::Yaml::Parser.new(validator)
      parser.data_binding = true

      begin
        parsed = parser.parse(appliance_definition)
      rescue Kwalify::KwalifyError => e
        raise ApplianceValidationError, "The appliance definition couldn't be parsed. [line #{e.linenum}, col #{e.column}] [#{e.path}] Make sure you use correct indentation (don't use tabs). If indentation is correct and you try to specify partition mount point, please quote it: \"/foo\" instead of /foo." if e.message =~ /document end expected \(maybe invalid tab char found\)/
        raise ApplianceValidationError, "The appliance definition couldn't be parsed. #{e}"
      end

      [parsed, parser.errors]
    end
  end
end
