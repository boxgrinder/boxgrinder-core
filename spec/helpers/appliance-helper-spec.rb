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

require 'boxgrinder-core/helpers/appliance-helper'

module BoxGrinder
  describe ApplianceHelper do

    before(:each) do
      @helper = ApplianceHelper.new(:log => Logger.new('/dev/null'))
    end

    it "should read definition from one file" do
      appliance_config = ApplianceConfig.new
      @helper.should_receive(:read_yaml).with('file.appl').and_return(appliance_config)
      @helper.read_definitions("file.appl").should == [[appliance_config], appliance_config]
    end

    it "should read definition from two files" do
      appliance_a = ApplianceConfig.new
      appliance_a.name = 'a'
      appliance_a.appliances << "b"

      appliance_b = ApplianceConfig.new
      appliance_b.name = 'b'

      @helper.should_receive(:read_yaml).ordered.with('a.appl').and_return(appliance_a)
      @helper.should_receive(:read_yaml).ordered.with('./b.appl').and_return(appliance_b)

      @helper.read_definitions("a.appl").should == [[appliance_a, appliance_b], appliance_a]
    end

    it "should read definitions from a tree file structure" do
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

      @helper.should_receive(:read_yaml).ordered.with('a.appl').and_return(appliance_a)
      @helper.should_receive(:read_yaml).ordered.with('./b2.appl').and_return(appliance_b2)
      @helper.should_receive(:read_yaml).ordered.with('./c2.appl').and_return(appliance_c2)
      @helper.should_receive(:read_yaml).ordered.with('./b1.appl').and_return(appliance_b1)
      @helper.should_receive(:read_yaml).ordered.with('./c1.appl').and_return(appliance_c1)

      @helper.read_definitions("a.appl").should == [[appliance_a, appliance_b2, appliance_c2, appliance_b1, appliance_c1], appliance_a]
    end

    describe "read_yaml" do
      it "should read default_repos and set to false" do
        YAML.should_receive(:load_file).with('default_repos_false.appl').and_return({'default_repos'=>false})
        @helper.read_yaml('default_repos_false.appl').default_repos.should == false
      end

      it "should read default_repos and set to true" do
        YAML.should_receive(:load_file).with('default_repos_true.appl').and_return({'default_repos'=>true})
        @helper.read_yaml('default_repos_true.appl').default_repos.should == true
      end

      it "should read default_repos but not set it" do
        YAML.should_receive(:load_file).with('default_repos_empty.appl').and_return({})
        @helper.read_yaml('default_repos_empty.appl').default_repos.should == nil
      end

      it "should read default_repos and raise" do
        YAML.should_receive(:load_file).with('default_repos_bad.appl').and_return({'default_repos'=>'something'})

        begin
          @helper.read_yaml("default_repos_bad.appl")
          raise 'Should raise'
        rescue => e
          e.message.should == 'default_repos_bad.appl: default_repos should be set to true or false'
        end
      end
    end
  end
end
