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
    it "should not load options from file if it doesn't exists" do
      ENV['BG_CONFIG_FILE'] = "doesntexists"

      config = Config.new
      config.size.should == 6
      config.force.should == false
    end

    it "should load empty config file" do
      ENV['BG_CONFIG_FILE'] = "#{File.dirname(__FILE__)}/../rspec/src/config/empty"

      config = Config.new
      config.size.should == 6
      config.force.should == false
      config.log_level.should == :info
    end

    it "should load config file" do
      ENV['BG_CONFIG_FILE'] = "#{File.dirname(__FILE__)}/../rspec/src/config/valid"

      config = Config.new
      config.size.should == 6
      config.force.should == true
      config.log_level.should == 'trace'
      config.dir.build.should == 'build'
      config.dir.root.should == 'root/dir'
    end
  end
end