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
require 'boxgrinder-core/schemas/appliance-transformers'
require 'boxgrinder-core/helpers/log-helper'

module BoxGrinder
  class ApplianceValidator < Kwalify::Validator

    def initialize(schema)
      super(schema) # Super constructor
    end

    def validate_hook(value, rule, path, errors)
      case rule.name
        when 'Repository' # enforce baseurl xor mirrorlist
          unless value['baseurl'].nil? ^ value['mirrorlist'].nil?
            errors << Kwalify::ValidationError.new("must specify either a baseurl or a mirrorlist, not both", path)
          end
        when 'Hardware' # enforce multiple of 64
          unless value['memory'].nil?
            unless value['memory']%64==0
              errors << Kwalify::ValidationError.new("'#{value}': not a valid memory size, it must be a multiple of 64", path)
            end
          end
      end
    end
  end

  class TransformHelper
    include ApplianceTransformers

    def initialize(options = {})
      @log = options[:log] || Logger.new(STDOUT)
    end

    def method_name(name)
      name.gsub(/[-\.]/, '_')
    end

    def transform(name, doc)
      begin
        self.send(self.method_name(name), doc)
      rescue
        #No conversion
      end
    end

    def method_missing(sym, *args, &block)
      @log.trace "No document conversion method found for '#{sym}'. Available conversion methods: [#{ApplianceTransformers::instance_methods(false).sort.join(", ")}]"
    end
  end

end
