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
require 'boxgrinder-core/helpers/appliance-definition-helper'
require 'boxgrinder-core/appliance-parser'

module BoxGrinder
  describe ApplianceDefinitionHelper do

    def prepare_helper
      @helper = ApplianceDefinitionHelper.new(:log => LogHelper.new(:level => :trace, :type => :stdout))
    end

    before(:each) do
      prepare_helper
    end

    describe ".read_definitions" do
      it "should pass all sample definitions that are not marked as invalid" do
        prepare_helper

        Dir.glob("#{File.dirname(__FILE__)}/../rspec/src/appliances/*.appl").each do |l|
          next if l =~ /invalid/
          @helper.read_definitions(l)
        end
      end

      it "should read definition from files with different extensions" do
        appliance_config = ApplianceConfig.new
        ['appl', 'yml', 'yaml'].each do |ext|
          prepare_helper
          @helper.appliance_parser.should_receive(:load_schemas)
          File.should_receive(:exists?).with("file.#{ext}").and_return(true)
          @helper.appliance_parser.should_receive(:parse_definition).with("file.#{ext}").and_return(appliance_config)
          @helper.read_definitions("file.#{ext}")
          configs = @helper.appliance_configs

          configs.should == [appliance_config]
        end
      end

      it "should read YAML definition from files with different content types" do
        appliance_config = ApplianceConfig.new

        ['application/x-yaml', 'text/yaml'].each do |type|
          prepare_helper
          @helper.appliance_parser.should_receive(:load_schemas)
          File.should_receive(:exists?).with("file").and_return(true)
          @helper.appliance_parser.should_receive(:parse_definition).with("file").and_return(appliance_config)
          @helper.read_definitions("file", type)
          configs = @helper.appliance_configs
          configs.should == [appliance_config]
          configs.first.should == appliance_config
        end
      end

      it "should read definition from two files" do
        @helper.appliance_parser.should_receive(:load_schemas).twice

        appliance_a = ApplianceConfig.new
        appliance_a.name = 'a'
        appliance_a.appliances << "b"

        appliance_b = ApplianceConfig.new
        appliance_b.name = 'b'

        File.should_receive(:exists?).ordered.with('a.appl').and_return(true)
        File.should_receive(:exists?).ordered.with('./b.appl').and_return(true)

        @helper.appliance_parser.should_receive(:parse_definition).ordered.with('a.appl').and_return(appliance_a)
        @helper.appliance_parser.should_receive(:parse_definition).ordered.with('./b.appl').and_return(appliance_b)

        @helper.read_definitions("a.appl")

        configs = @helper.appliance_configs
        configs.should == [appliance_a, appliance_b]
        configs.first.should == appliance_a
      end

      it "should read definitions from a tree file structure" do
        @helper.appliance_parser.should_receive(:load_schemas).exactly(5).times

        appliance_a = ApplianceConfig.new
        appliance_a.name = 'a'
        appliance_a.appliances << "b1"
        appliance_a.appliances << "b2"

        appliance_b1 = ApplianceConfig.new
        appliance_b1.name = 'b1'
        appliance_b1.appliances << "c1"

        appliance_b2 = ApplianceConfig.new
        appliance_b2.name = 'b2'
        appliance_b2.appliances << "c2"

        appliance_c1 = ApplianceConfig.new
        appliance_c1.name = 'c1'

        appliance_c2 = ApplianceConfig.new
        appliance_c2.name = 'c2'

        File.should_receive(:exists?).ordered.with('a.appl').and_return(true)
        File.should_receive(:exists?).ordered.with('./b2.appl').and_return(true)
        File.should_receive(:exists?).ordered.with('./c2.appl').and_return(true)
        File.should_receive(:exists?).ordered.with('./b1.appl').and_return(true)
        File.should_receive(:exists?).ordered.with('./c1.appl').and_return(true)

        @helper.appliance_parser.should_receive(:parse_definition).ordered.with('a.appl').and_return(appliance_a)
        @helper.appliance_parser.should_receive(:parse_definition).ordered.with('./b2.appl').and_return(appliance_b2)
        @helper.appliance_parser.should_receive(:parse_definition).ordered.with('./c2.appl').and_return(appliance_c2)
        @helper.appliance_parser.should_receive(:parse_definition).ordered.with('./b1.appl').and_return(appliance_b1)
        @helper.appliance_parser.should_receive(:parse_definition).ordered.with('./c1.appl').and_return(appliance_c1)

        @helper.read_definitions("a.appl")

        configs = @helper.appliance_configs
        configs.should == [appliance_a, appliance_b2, appliance_c2, appliance_b1, appliance_c1]
        configs.first.should == appliance_a
      end

      # https://issues.jboss.org/browse/BGBUILD-60
      it "should read definitions from a tree file structure based on same appliance" do
        @helper.appliance_parser.should_receive(:load_schemas).exactly(4).times

        appliance_a = ApplianceConfig.new
        appliance_a.name = 'a'
        appliance_a.appliances << "b1"
        appliance_a.appliances << "b2"

        appliance_b1 = ApplianceConfig.new
        appliance_b1.name = 'b1'
        appliance_b1.appliances << "c"

        appliance_b2 = ApplianceConfig.new
        appliance_b2.name = 'b2'
        appliance_b2.appliances << "c"

        appliance_c = ApplianceConfig.new
        appliance_c.name = 'c'

        File.should_receive(:exists?).ordered.with('a.appl').and_return(true)
        File.should_receive(:exists?).ordered.with('./b2.appl').and_return(true)
        File.should_receive(:exists?).ordered.with('./c.appl').and_return(true)
        File.should_receive(:exists?).ordered.with('./b1.appl').and_return(true)

        @helper.appliance_parser.should_receive(:parse_definition).ordered.with('a.appl').and_return(appliance_a)
        @helper.appliance_parser.should_receive(:parse_definition).ordered.with('./b2.appl').and_return(appliance_b2)
        @helper.appliance_parser.should_receive(:parse_definition).ordered.once.with('./c.appl').and_return(appliance_c)
        @helper.appliance_parser.should_receive(:parse_definition).ordered.with('./b1.appl').and_return(appliance_b1)

        @helper.read_definitions("a.appl")

        configs = @helper.appliance_configs
        configs.should == [appliance_a, appliance_b2, appliance_c, appliance_b1]
        configs.first.should == appliance_a
      end

      it "should read YAML content instead of loading a file" do
        yaml = "name: abc\nos:\n  name: fedora\n  version: '13'\npackages:\n  - @core\nhardware:\n  partitions:\n    \"/\":\n      size: 6"
        appliance = @helper.read_definitions(yaml).last

        appliance.name.should == 'abc'
        appliance.os.version.should == '13'
        appliance.hardware.partitions['/']['size'].should == 6
        appliance.default_repos.should == true
      end

      it "should read YAML content instead of loading a file with default repos disabled" do
        yaml = "name: abc\nos:\n  name: fedora\n  version: '13'\npackages:\n  - @core\nhardware:\n  partitions:\n    \"/\":\n      size: 6\ndefault_repos: false"
        appliance = @helper.read_definitions(yaml).last

        appliance.name.should == 'abc'
        appliance.os.version.should == '13'
        appliance.hardware.partitions['/']['size'].should == 6
        appliance.default_repos.should == false
      end

      it "should read invalid YAML content" do #ApplianceValidationError: :
        lambda { @helper.read_definitions("@$FEWYERTH") }.should raise_error(ApplianceValidationError, "The appliance definition was invalid according to schema 0.9.6. See log for details.")
      end

      it "should catch exception if YAML parsing raises it" do
        lambda { @helper.read_definitions("!!") }.should raise_error(ApplianceValidationError, "The appliance definition was invalid according to schema 0.9.6. See log for details.")
      end

      it "should catch exception if YAML file parsing raises it" do
        lambda { @helper.read_definitions("#{File.dirname(__FILE__)}/../rspec/src/appliances/invalid-yaml.appl") }.should raise_error(ApplianceValidationError, "The appliance definition was invalid according to schema 0.9.6. See log for details.")
      end

      it "should return nil of unsupported file format" do
        File.should_receive(:exists?).with("file.xmdfl").and_return(true)
        @helper.read_definitions("file.xmdfl").should == nil
      end

      #Do more extensive tests in the parser/validator itself
      it "should allow legacy package inclusion styles" do #@helper.appliance_validator.should_receive(:load_specification_files).
        #@helper = ApplianceDefinitionHelper.new(:log => LogHelper.new(:level => :trace, :type => :stdout))
        @helper.read_definitions("#{File.dirname(__FILE__)}/../rspec/src/appliances/legacy.appl")
        @helper.appliance_configs.last.packages.should == ['squid', 'boxgrinder-rest']
      end

      # https://issues.jboss.org/browse/BGBUILD-150
      context "cyclical dependency" do
        it "should stop reading appliances when appliance was already read" do
          @helper.appliance_parser.should_receive(:load_schemas).twice

          appliance_a = ApplianceConfig.new
          appliance_a.name = 'a'
          appliance_a.appliances << "b"

          appliance_b = ApplianceConfig.new
          appliance_b.name = 'b'
          appliance_b.appliances << "a"


          File.should_receive(:exists?).with('a.appl').and_return(true)
          File.should_receive(:exists?).with('./b.appl').and_return(true)
          File.should_not_receive(:exists?).ordered.with('./a.appl')

          @helper.appliance_parser.should_receive(:parse_definition).ordered.with('a.appl').and_return(appliance_a)
          @helper.appliance_parser.should_receive(:parse_definition).ordered.with('./b.appl').and_return(appliance_b)
          @helper.appliance_parser.should_not_receive(:parse_definition).ordered.with('./a.appl')

          @helper.read_definitions("a.appl")
        end
      end
    end
  end
end
