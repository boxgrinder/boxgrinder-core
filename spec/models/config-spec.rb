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
require 'boxgrinder-core/models/config'

module BoxGrinder
  describe Config do

    def get_config
      # Some extra challenges due to calls being in initialize
      Config.any_instance.stub(:populate_user_ids!)
      config = Config.new
      config
    end

    it "should not load options from file if it doesn't exist" do
      ENV['BG_CONFIG_FILE'] = ""

      lambda { get_config
      }.should raise_error(RuntimeError, "You specified empty configuration file path. Please make sure you set correct path for BG_CONFIG_FILE environment variable.")
    end

    it "should load empty config file" do
      ENV['BG_CONFIG_FILE'] = "#{File.dirname(__FILE__)}/../rspec/src/config/empty"

      config = get_config
      config.force.should == false
      config.log_level.should == :info
    end

    it "should load config file" do
      ENV['BG_CONFIG_FILE'] = "#{File.dirname(__FILE__)}/../rspec/src/config/valid"

      config = get_config
      config.force.should == true
      config.log_level.should == 'trace'
      config.dir.build.should == 'build'
      config.dir.root.should == 'root/dir'
    end

    it "should raise a file not found error if BG_CONFIG_FILE is set, but the path is invalid" do
      ENV['BG_CONFIG_FILE'] = "leo/tol/stoy"
      lambda { get_config }.should raise_error(RuntimeError, "Configuration file 'leo/tol/stoy' couldn't be found. Please make sure you set correct path for BG_CONFIG_FILE environment variable.")
    end

    it "should raise if the specified config file is whitespace" do
      ENV['BG_CONFIG_FILE'] = "  "

      lambda {
        config = get_config
      }.should raise_error(RuntimeError, "You specified empty configuration file path. Please make sure you set correct path for BG_CONFIG_FILE environment variable.")
    end

    it "should merge platform" do
      # Make sure we don't have the variable defined anymore
      ENV.delete('BG_CONFIG_FILE')
      config = get_config.merge(:platform => :ec2)
      config.platform.should == :ec2
    end

    context ".populate_user_ids!" do
      before(:each) do
        # Work-around due to unstubbing not working properly.
        ['LOGNAME', 'SUDO_USER'].each{|e| ENV.delete(e)}
        @user = mock('gravy', :uid => 347, :gid => 547)
        @root = mock('root', :uid => 0, :gid => 0)
        Etc.stub!(:getpwnam).and_return(@user)
        @config = Config.new
      end


      it "should discover a user and group when under su" do
        ENV['LOGNAME'] = 'gravy1'
        ['SUDO_USER', 'LOGNAME'].each{|v| puts "From config-spec.rb: #{ENV[v]}"}

        Process.should_receive(:uid).and_return(99)
        Process.should_receive(:gid).and_return(79)
        Etc.should_receive(:getpwnam).with('gravy1').and_return(@user)

        @config.populate_user_ids!
        @config.uid.should == 347
        @config.gid.should == 547
      end

      it "should discover a user and group when under sudo" do
        ENV['SUDO_USER'] = 'gravy2'
        Process.should_receive(:uid).and_return(99)
        Process.should_receive(:gid).and_return(79)
        Etc.should_receive(:getpwnam).with('gravy2').and_return(@user)

        @config.populate_user_ids!
        @config.uid.should == 347
        @config.gid.should == 547
      end

      it "should set process uid/gid if variables are not set" do
        Process.should_receive(:uid).and_return(23)
        Process.should_receive(:gid).and_return(26)

        @config.populate_user_ids!
        @config.uid.should == 23
        @config.gid.should == 26
      end

      it "should return process uid/gid if user does not exist" do
        ENV['SUDO_USER'] = 'fakegravy'
        Process.should_receive(:uid).and_return(23)
        Process.should_receive(:gid).and_return(26)
        Etc.should_receive(:getpwnam).with('fakegravy').and_raise(ArgumentError)

        @config.populate_user_ids!
        @config.uid.should == 23
        @config.gid.should == 26
      end
    end
  end
end
