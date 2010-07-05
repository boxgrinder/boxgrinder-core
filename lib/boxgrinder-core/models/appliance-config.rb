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
require 'rbconfig'

module BoxGrinder
  class ApplianceConfig
    def initialize
      @name     = nil
      @summary  = nil

      @os = OpenStruct.new

      @os.name      = nil
      @os.version   = nil
      @os.password  = nil

      @hardware = OpenStruct.new

      @hardware.cpus      = APPLIANCE_DEFAULTS[:hardware][:cpus]
      @hardware.memory    = APPLIANCE_DEFAULTS[:hardware][:memory]
      @hardware.network   = APPLIANCE_DEFAULTS[:hardware][:network]

      @post = {}

      @packages = OpenStruct.new
      @packages.includes = []
      @packages.excludes = []

      @appliances   = []
      @repos        = []

      @version      = 1
      @release      = 0
    end

    attr_reader :os
    attr_reader :hardware
    attr_reader :path
    attr_reader :file
    attr_reader :post

    attr_accessor :packages
    attr_accessor :repos
    attr_accessor :appliances
    attr_accessor :summary
    attr_accessor :name
    attr_accessor :version
    attr_accessor :release

    def init
      init_arch
      initialize_paths
      self
    end

    def init_arch
      @hardware.arch = RbConfig::CONFIG['target_cpu']
      self
    end

    def initialize_paths
      @path = OpenStruct.new

      @path.dir = OpenStruct.new
      @path.dir.raw = OpenStruct.new
      @path.dir.ec2 = OpenStruct.new
      @path.dir.vmware = OpenStruct.new

      @path.file = OpenStruct.new
      @path.file.raw = OpenStruct.new
      @path.file.ec2 = OpenStruct.new
      @path.file.vmware = OpenStruct.new
      @path.file.vmware.personal = OpenStruct.new
      @path.file.vmware.enterprise = OpenStruct.new

      @path.dir.packages = "build/#{appliance_path}/packages"

      @path.dir.build = "build/#{appliance_path}"

      @path.dir.raw.build = "build/#{appliance_path}/raw"
      @path.dir.raw.build_full = "build/#{appliance_path}/raw/#{@name}"

      @path.dir.ec2.build = "build/#{appliance_path}/ec2"
      @path.dir.ec2.bundle = "#{@path.dir.ec2.build}/bundle"

      @path.dir.vmware.build = "build/#{appliance_path}/vmware"
      @path.dir.vmware.personal = "#{@path.dir.vmware.build}/personal"
      @path.dir.vmware.enterprise = "#{@path.dir.vmware.build}/enterprise"

      @path.file.raw.kickstart = "#{@path.dir.raw.build}/#{@name}.ks"
      @path.file.raw.config = "#{@path.dir.raw.build}/#{@name}.cfg"
      @path.file.raw.yum = "#{@path.dir.raw.build}/#{@name}.yum.conf"
      @path.file.raw.disk = "#{@path.dir.raw.build_full}/#{@name}-sda.raw"
      @path.file.raw.xml = "#{@path.dir.raw.build_full}/#{@name}.xml"

      @path.file.ec2.disk = "#{@path.dir.ec2.build}/#{@name}.ec2"
      @path.file.ec2.manifest = "#{@path.dir.ec2.bundle}/#{@name}-sda.raw.manifest.xml"

      @path.file.vmware.disk = "#{@path.dir.vmware.build}/#{@name}.raw"
      @path.file.vmware.personal.vmx = "#{@path.dir.vmware.personal}/#{@name}.vmx"
      @path.file.vmware.personal.vmdk = "#{@path.dir.vmware.personal}/#{@name}.vmdk"
      @path.file.vmware.personal.disk = "#{@path.dir.vmware.personal}/#{@name}.raw"
      @path.file.vmware.enterprise.vmx = "#{@path.dir.vmware.enterprise}/#{@name}.vmx"
      @path.file.vmware.enterprise.vmdk = "#{@path.dir.vmware.enterprise}/#{@name}.vmdk"
      @path.file.vmware.enterprise.disk = "#{@path.dir.vmware.enterprise}/#{@name}.raw"

      @path.file.package = {
              :raw => {
                      :tgz => "#{@path.dir.packages}/#{@name}-#{@version}.#{@release}-#{@hardware.arch}-raw.tgz",
                      :zip => "#{@path.dir.packages}/#{@name}-#{@version}.#{@release}-#{@hardware.arch}-raw.zip"
              },
              :vmware => {
                      :tgz => "#{@path.dir.packages}/#{@name}-#{@version}.#{@release}-#{@hardware.arch}-VMware.tgz",
                      :zip => "#{@path.dir.packages}/#{@name}-#{@version}.#{@release}-#{@hardware.arch}-VMware.zip"
              }
      }
      self
    end

    # used to checking if configuration differs from previous in appliance-kickstart
    def hash
      "#{@name}-#{@summary}-#{@version}-#{@release}-#{@os.name}-#{@os.version}-#{@os.password}-#{@hardware.cpus}-#{@hardware.memory}-#{@hardware.partitions}-#{@appliances}".hash
    end

    # TODO remove this, leave only :name
    def simple_name
      @name
    end

    def os_path
      "#{@os.name}/#{@os.version}"
    end

    def main_path
      "#{@hardware.arch}/#{os_path}"
    end

    def appliance_path
      "appliances/#{main_path}/#{@name}"
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

    def os_family
      return :linux if [ 'fedora' ].include?( @os.name )
      return :unknown
    end
  end
end
