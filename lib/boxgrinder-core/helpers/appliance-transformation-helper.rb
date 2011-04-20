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

module BoxGrinder
  class ApplianceTransformationHelper
    def initialize(latest_schema_version, options = {})
      @latest_schema_version = latest_schema_version
      @log = options[:log] || LogHelper.new

      @versions = ['0.9.0']
    end

    def transform(appliance_definition, version)
      return appliance_definition if version == @latest_schema_version

      @log.debug "Transforming appliance definition from schema version #{version} to #{@latest_schema_version}..."

      transformations = [version]
      definition = appliance_definition

      @versions.each do |v|
        if (transformations.last <=> v) < 0
          @log.trace "Round #{transformations.size}: transforming from version #{transformations.last} to #{v}..."
          definition = self.send("to_#{v.gsub(/[-\.]/, '_')}", definition)
          transformations << v
        end
      end

      @log.debug "Following transformation were applied: #{transformations.join(' => ')}." if transformations.size > 1

      definition
    end

    def to_0_9_0(appliance_definition)
      packages = appliance_definition['packages']['includes']
      @log.warn "BoxGrinder no longer supports package exclusion, the following packages will be not be explicitly excluded: #{appliance_definition['packages']['excludes'].join(", ")}."
      appliance_definition['packages'] = packages
      appliance_definition
    end
  end
end
