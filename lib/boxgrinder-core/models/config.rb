# JBoss, Home of Professional Open Source
# Copyright 2009, Red Hat Middleware LLC, and individual contributors
# by the @authors tag. See the copyright.txt in the distribution for a
# full listing of individual contributors.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of
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

require 'boxgrinder-core/defaults'
require 'ostruct'

module BoxGrinder
  class Config
    def initialize

      @name = DEFAULT_PROJECT_CONFIG[:name]

      @dir = OpenStruct.new
      @dir.root        = `pwd`.strip
      @dir.base        = "#{File.dirname( __FILE__ )}/../../"
      @dir.build       =  DEFAULT_PROJECT_CONFIG[:dir_build]
      @dir.top         = "#{@dir.build}/topdir"
      @dir.src_cache   =  DEFAULT_PROJECT_CONFIG[:dir_src_cache]
      @dir.rpms_cache  =  DEFAULT_PROJECT_CONFIG[:dir_rpms_cache]
      @dir.specs       =  DEFAULT_PROJECT_CONFIG[:dir_specs]
      @dir.appliances  =  DEFAULT_PROJECT_CONFIG[:dir_appliances]
      @dir.src         =  DEFAULT_PROJECT_CONFIG[:dir_src]
      @dir.kickstarts  =  DEFAULT_PROJECT_CONFIG[:dir_kickstarts]

      @config_file  = ENV['BG_CONFIG_FILE'] || "#{ENV['HOME']}/.boxgrinder/config"

      @version = OpenStruct.new
      @version.version = DEFAULT_PROJECT_CONFIG[:version]
      @version.release = DEFAULT_PROJECT_CONFIG[:release]

      @files = OpenStruct.new
      @data = {}

      if File.exists?( @config_file )
        @data = YAML.load_file( @config_file )
        @data['gpg_password'].gsub!(/\$/, "\\$") unless @data['gpg_password'].nil? or @data['gpg_password'].length == 0
        @dir.rpms_cache = @data['rpms_cache'] || @dir.rpms_cache
        @dir.src_cache  = @data['src_cache']  || @dir.src_cache
      end
    end

    def version_with_release
      @version.version + ((@version.release.nil? or @version.release.empty?) ? "" : "-" + @version.release)
    end

    attr_accessor :name
    attr_accessor :version
    attr_accessor :release
    attr_accessor :config_file
    attr_reader :files

    attr_reader :data
    attr_reader :dir
  end
end
