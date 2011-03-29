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