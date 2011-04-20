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
require 'boxgrinder-core/helpers/log-helper'

module BoxGrinder
  class ApplianceValidator < Kwalify::Validator
    def initialize(schema)
      super(schema) # Super constructor
    end

    def validate_hook(value, rule, path, errors)
      case rule.name
        when 'Repository' # enforce baseurl xor mirrorlist
          errors << Kwalify::ValidationError.new("Please specify either a baseurl or a mirrorlist.", path) unless value['baseurl'].nil? ^ value['mirrorlist'].nil?
        when 'Hardware' # enforce multiple of 64
          errors << Kwalify::ValidationError.new("Specified memory amount: #{value['memory']} is invalid. The value must be a multiple of 64.", path) unless value['memory'].nil? or value['memory']%64==0
      end
    end
  end
end
