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
  module ApplianceTransformers
    def appliance_schema_0_9_x(doc)
      #Not necessary until 0.9.x is superseded
      doc
    end

    def appliance_schema_0_8_x(doc)
      packages = doc['packages']['includes']
      puts "[Demo msg, conversion worked] BoxGrinder no longer supports package exclusion, the following packages will be not be explicitly excluded: #{doc['packages']['excludes'].join(",")}"
      doc['packages'] = packages
      doc
    end
  end
end
