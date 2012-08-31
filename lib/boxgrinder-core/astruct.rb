require 'boxgrinder-core/astruct_mixin'

module BoxGrinder

  class AStruct < Hash

    include AStructMixin

    def initialize(hash=nil, cascade_for_nils=true)
      cascade_for_nils! if cascade_for_nils
      hash.each { |k,v| self[k]=v } if hash
    end

  end

end
