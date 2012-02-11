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
require 'boxgrinder-core/appliance-parser'
require 'boxgrinder-core/helpers/log-helper'

module BoxGrinder
  describe ApplianceParser do
    before(:each) do
      @log = LogHelper.new(:level => :trace, :type => :stdout)
      @parser = ApplianceParser.new(:log => @log)
    end

    describe ".load_schemas" do
      it "should load all available schemas" do
        YAML.should_receive(:load_file).with('filea').and_return({'version' => '0.8.0'})
        YAML.should_receive(:load_file).with('fileb').and_return({'version' => '0.9.0'})

        Dir.should_receive(:glob).with(an_instance_of(String)).and_return(['filea', 'fileb'])

        @parser.load_schemas
        @parser.instance_variable_get(:@schemas).should == {'0.8.0' => {'version' => '0.8.0'}, '0.9.0' => {'version' => '0.9.0'}}
      end
    end

    describe ".parse_definition" do
      it "should raise exception because the appliance definition is invalid" do
        @parser.load_schemas

        lambda {
          @parser.parse_definition(File.read("#{File.dirname(__FILE__)}/rspec/src/appliances/invalid-yaml.appl"), false)
        }.should raise_error(ApplianceValidationError, "The appliance definition was invalid according to schema 0.9.6. See log for details.")
      end

      it "should validate 0.9.0 version definition without error" do
        @parser.load_schemas
        definition = @parser.parse_definition(File.read("#{File.dirname(__FILE__)}/rspec/src/appliances/0.9.x.appl"), false)

        definition.os.password.should == 'boxgrinder-ftw'
        definition.packages.size.should == 2
      end

      it "should validate 0.8.0 version definition without error" do
        @parser.load_schemas
        definition = @parser.parse_definition("#{File.dirname(__FILE__)}/rspec/src/appliances/0.8.x.appl")

        definition.os.password.should == 'boxgrinder-ftw'
        definition.packages.size.should == 3
      end
    end

    describe ".parse" do
      it "should parse the doc" do
        @parser.load_schemas
        definition = File.read("#{File.dirname(__FILE__)}/rspec/src/appliances/repo.appl")
        schemas = @parser.instance_variable_get(:@schemas)
        schema = schemas[schemas.keys.first]
        schema.delete('version')
        parsed, errors = @parser.parse(schema, definition)

        parsed['repos'].first['baseurl'].should == 'http://repo.boxgrinder.org/packages/#OS_NAME#/#OS_VERSION#/RPMS/#ARCH#'
      end
    end
  end
end
