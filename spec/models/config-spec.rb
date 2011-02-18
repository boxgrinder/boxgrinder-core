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

require 'boxgrinder-core/models/config'

module BoxGrinder
  describe Config do
    before(:each) do
      ENV['BG_CONFIG_FILE'] = "doesntexists"
    end

    it "should not load options from file if it doesn't exists" do
      config = Config.new
      config.force.should == false
    end

    it "should load empty config file" do
      ENV['BG_CONFIG_FILE'] = "#{File.dirname(__FILE__)}/../rspec/src/config/empty"

      config = Config.new
      config.force.should == false
      config.log_level.should == :info
    end

    it "should load config file" do
      ENV['BG_CONFIG_FILE'] = "#{File.dirname(__FILE__)}/../rspec/src/config/valid"

      config = Config.new
      config.force.should == true
      config.log_level.should == 'trace'
      config.dir.build.should == 'build'
      config.dir.root.should == 'root/dir'
    end

    it "should merge platform" do
      config = Config.new.merge(:platform => :ec2)

      config.platform.should == :ec2
    end

    context "host OS information" do
      before(:each) do
        File.should_receive(:exists?).with('doesntexists').and_return(false)
        File.should_receive(:exists?).with('/etc/redhat-release').and_return(true)
      end

      it "should read os info for Fedora 14" do
        File.should_receive(:read).with('/etc/redhat-release').and_return('Fedora release 14 (Laughlin)')

        config = Config.new
        config.os.name.should == 'fedora'
        config.os.version.should == '14'
        config.os.codename.should == 'Laughlin'
        config.os.description.should == 'Fedora'
      end

      it "should read os info for RHEL 6" do
        File.should_receive(:read).with('/etc/redhat-release').and_return('Red Hat Enterprise Linux Server release 6.0 (Santiago)')

        config = Config.new
        config.os.name.should == 'rhel'
        config.os.version.should == '6'
        config.os.codename.should == 'Santiago'
        config.os.description.should == 'Red Hat Enterprise Linux Server'
      end

      it "should read os info for CentOS 5" do
        File.should_receive(:read).with('/etc/redhat-release').and_return('CentOS release 5.5 (Final)')

        config = Config.new
        config.os.name.should == 'centos'
        config.os.version.should == '5'
        config.os.codename.should == 'Final'
        config.os.description.should == 'CentOS'
      end
    end
  end
end