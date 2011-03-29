require 'kwalify'
require 'boxgrinder-core/schemas/appliance-transformers'
require 'boxgrinder-core/helpers/log-helper'

module BoxGrinder
  class ApplianceValidator < Kwalify::Validator

    def initialize( schema )
      super(schema)#Super constructor
    end

    def validate_hook(value, rule, path, errors)
      case rule.name
        when 'Repository' #enforce baseurl xor mirrorlist
          unless value['baseurl'].nil? ^ value['mirrorlist'].nil?
            errors << Kwalify::ValidationError.new("must specify either a baseurl or a mirrorlist, not both", path)
          end
        when 'Hardware' #enforce multiple of 64
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

    def method_name( name )
      name.gsub(/[-\.]/,'_')
    end

    def transform(name, doc)
      begin
        self.send(self.method_name(name),doc)
      rescue
        #No conversion
      end
    end

    def method_missing(sym, *args, &block)
      @log.trace "No document conversion method found for '#{sym}'. Available conversion methods: [#{ApplianceTransformers::instance_methods(false).sort.join(", ")}]"
    end
  end
  
end