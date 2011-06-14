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
require 'boxgrinder-core/models/config'

module BoxGrinder
  describe Config do
    it "should not load options from file if it doesn't exist" do
      ENV['BG_CONFIG_FILE'] = ""

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

    it "should raise a file not found error if BG_CONFIG_FILE is set, but the path is invalid" do
      ENV['BG_CONFIG_FILE'] = "leo/tol/stoy"
      lambda { Config.new }.should raise_error(Errno::ENOENT)
    end

    it "should merge platform" do
      ENV['BG_CONFIG_FILE'] = "  "

      config = Config.new.merge(:platform => :ec2)

      config.platform.should == :ec2
    end
  end
end
