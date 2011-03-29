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

require 'boxgrinder-core/validators/appliance-parser-validator'
require 'boxgrinder-core'

module BoxGrinder
  describe ApplianceParserValidator do

    before(:all) do#load in the schemas
      @appliance_validator=ApplianceParserValidator.new(Dir.glob("#{$BOXGRINDER_ROOT}/boxgrinder-core/schemas/{*.yaml,*.yml}"))
    end

#    describe ".load_schema" do
#      it "should read a single schema file" do
##        yaml_document={}
##        File.should_receive(:open).with("some-schema.yaml").and_return(yaml_document)
##        @appliance_validator.should_receive(:parse_paths).with("[some-schema.yaml]")
##        @appliance_validator.load_schema_files("some-schema.yaml")
#      end
#
#      it "should read a list of schema files " do
#
#      do
#
#      it "should calculate schema names by using the filename" do
#
#      end
#    end


#    it "should load, parse and verify BoxGrinder schema files against the internal Kwalify meta-schema" do
#      #Must do it manually for this test to make sense
#      av=ApplianceParserValidator.new()
#      schemas = Dir.glob("#{$BOXGRINDER_ROOT}/boxgrinder-core/schemas/{*.yaml,*.yml}")
#
#      av.load_schema_files(*schemas)
#      av.schemas.size.should == 2
#
#      schemas.each do |s|#Calculate schema names
#        s=File.basename(s)
#        s.gsub!(/\.[^\.]+$/,'')#remove file extension
#        s.gsub!(/[- ]/,'_')
#        #Determine whether it exists, if yes, then it verified OK
#        av.schemas.has_key?(s).should == true
#        av.schemas[s].should_not == nil
#        #Correctness of the data is reliant upon Kwalify meta-schema
#      end
#    end
  end
end
