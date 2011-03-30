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
require 'boxgrinder-core/helpers/log-helper'

module BoxGrinder
  describe LogHelper do

    before(:each) do
      @helper = LogHelper.new
      @helper.instance_variable_set(:@stdout_log, Logger.new('/dev/null') )
      @helper.instance_variable_set(:@file_log, Logger.new('/dev/null') )
    end

    it "should initialize properly without arguments with good log levels" do
      FileUtils.should_receive(:mkdir_p).once.with("log")

      @helper = LogHelper.new

      stdout_log  = @helper.instance_variable_get(:@stdout_log)
      file_log    = @helper.instance_variable_get(:@file_log)

      stdout_log.level.should == Logger::INFO
      file_log.level.should == Logger::TRACE
    end

    it "should allow to log in every known log level" do
      @helper.fatal( "fatal" )
      @helper.debug( "debug" )
      @helper.error( "error" )
      @helper.warn( "warn" )
      @helper.info( "info" )
    end

    it "should change log level" do
      FileUtils.should_receive(:mkdir_p).once.with("log")

      @helper = LogHelper.new( :level => "debug" )

      stdout_log  = @helper.instance_variable_get(:@stdout_log)
      file_log    = @helper.instance_variable_get(:@file_log)

      stdout_log.level.should == Logger::DEBUG
      file_log.level.should == Logger::TRACE
    end

    it "should change log level" do
      FileUtils.should_receive(:mkdir_p).once.with("log")

      @helper = LogHelper.new( :level => "doesntexists" )

      stdout_log  = @helper.instance_variable_get(:@stdout_log)
      file_log    = @helper.instance_variable_get(:@file_log)

      stdout_log.level.should == Logger::INFO
      file_log.level.should == Logger::TRACE
    end
  end
end
