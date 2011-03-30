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
  class ApplianceTransformerHelper
    def initialize(options = {})
      @log = options[:log] || LogHelper.new
    end

    def transform(doc, version)
      method = version.gsub(/[-\.]/, '_')

      if self.respond_to?(method)
        return self.send(method, doc)
      else
        @log.warn "Couldn't found transformation for #{version}..."
        return doc
      end
    end

    def appliance_schema_0_9_x(doc)
      #Not necessary until 0.9.x is superseded
      doc
    end

    def appliance_schema_0_8_0(doc)
      packages = doc['packages']['includes']
      @log.warn "BoxGrinder no longer supports package exclusion, the following packages will be not be explicitly excluded: #{doc['packages']['excludes'].join(",")}"
      doc['packages'] = packages
      doc
    end
  end
end
