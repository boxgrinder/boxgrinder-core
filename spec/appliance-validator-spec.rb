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

require 'rubygems'
require 'rspec'
require 'boxgrinder-core/appliance-validator'
require 'hashery/opencascade'

module BoxGrinder
  describe ApplianceValidator do
    before(:each) do
      schema = YAML.load_file("#{File.dirname(__FILE__)}/../lib/boxgrinder-core/schemas/appliance_schema_0.9.0.yaml")
      schema.delete('version')

      @validator = ApplianceValidator.new(schema)
    end

    describe ".validate_hook" do
      context "repository" do
        it "should generate error when no baseurl or mirrorlist is specified for repository" do
          a = []
          @validator.validate_hook({}, OpenCascade.new(:name => 'Repository'), '/', a)
          a.size.should == 1
          a.first.message.should == 'Please specify either a baseurl or a mirrorlist.'
        end

        it "should generate error when both baseurl and mirrorlist are specified for repository" do
          a = []
          @validator.validate_hook({'baseurl' => 'abc', 'mirrorlist' => 'def'}, OpenCascade.new(:name => 'Repository'), '/', a)
          a.size.should == 1
          a.first.message.should == 'Please specify either a baseurl or a mirrorlist.'
        end

        it "should pass if baseurl or mirrorlist is specified for repository" do
          a = []
          @validator.validate_hook({'baseurl' => 'abc'}, OpenCascade.new(:name => 'Repository'), '/', a)
          a.size.should == 0
        end
      end

      context "hardware" do
        it "should allow only multiplicity of 64 for memory" do
          a = []
          @validator.validate_hook({'memory' => 235}, OpenCascade.new(:name => 'Hardware'), '/', a)
          a.size.should == 1
          a.first.message.should == "Specified memory amount: 235 is invalid. The value must be a multiple of 64."
        end

        it "should pass if the memory is 256" do
          a = []
          @validator.validate_hook({'memory' => 256}, OpenCascade.new(:name => 'Hardware'), '/', a)
          a.size.should == 0
        end
      end
    end
  end
end
