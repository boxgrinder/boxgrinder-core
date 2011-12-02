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
require 'hashery/opencascade'

module BoxGrinder
  class ApplianceConfig
    def initialize
      @name = nil
      @summary = nil

      @variables = {}

      @os = OpenCascade.new

      @os.name = nil
      @os.version = nil
      @os.password = nil
      @os.pae = true

      @hardware = OpenCascade.new

      @hardware.cpus = 1
      @hardware.memory = 256
      @hardware.network = 'NAT'
      @hardware.partitions = {"/" => {'size' => 1}}

      @default_repos = true

      @post = {}
      @files = {}

      @packages = []
      @appliances = []
      @repos = []

      @version = 1
      @release = 0
    end

    attr_reader :variables
    attr_reader :os
    attr_reader :hardware
    attr_reader :path
    attr_reader :post
    attr_reader :files

    attr_accessor :packages
    attr_accessor :repos
    attr_accessor :appliances
    attr_accessor :summary
    attr_accessor :name
    attr_accessor :version
    attr_accessor :release
    attr_accessor :default_repos

    def init
      init_arch
      initialize_paths
      self
    end

    def init_arch
      @hardware.arch = `uname -m`.chomp.strip
      @hardware.base_arch = is64bit? ? "x86_64" : "i386"
      self
    end

    def initialize_paths
      @path = OpenCascade.new

      @path.os = "#{@os.name}/#{@os.version}"
      @path.version = "#{@version}.#{@release}"
      @path.main = "#{@hardware.arch}/#{@path.os}"
      @path.appliance = "appliances/#{@path.main}/#{@name}/#{@path.version}"
      @path.build = "build/#{@path.appliance}"

      self
    end

    def all_values(input=nil)
      avoid	= ['@variables']
      input = (self.instance_variables - avoid).
        collect{ |v| self.instance_variable_get(v) } if input.nil?

      vars = input.inject([]) do |arr, var|
        case var
          when Hash
            arr.concat(all_values(var.values))
          when Array
            arr.concat(all_values(var))
          when String
            arr.push var
          end
        arr
        end
      vars
    end

    # Returns default filesystem type for current OS
    def default_filesystem_type
      fs = 'ext4'

# Since RHEL 5.6 the default filesystem is ext4
#
#      case @os.name
#        when 'rhel', 'centos'
#          case @os.version
#            when '5'
#              fs = 'ext3'
#          end
#      end

      fs
    end

    # used to checking if configuration differs from previous in appliance-kickstart
    def hash
      "#{@name}-#{@summary}-#{@version}-#{@release}-#{@os.name}-#{@os.version}-#{@os.password}-#{@hardware.cpus}-#{@hardware.memory}-#{@hardware.partitions}-#{@appliances}".hash
    end

    def eql?(other)
      hash.eql?(other.hash)
    end

    def is64bit?
      @hardware.arch.eql?("x86_64")
    end

    def clone
      Marshal::load(Marshal.dump(self))
    end
  end
end
