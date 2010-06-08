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

require 'boxgrinder-core/validators/errors'

module BoxGrinder
  class ApplianceConfigHelper

    def initialize(appliance_configs)
      @appliance_configs  = appliance_configs.values.reverse
    end

    def merge(appliance_config)
      @appliance_config = appliance_config

      prepare_os
      prepare_appliances

      merge_hardware
      merge_repos
      merge_packages
      merge_post_operations

      @appliance_config
    end

    protected

    def merge_hardware
      merge_cpus
      merge_partitions
      merge_memory
    end

    def merge_cpus
      merge_field('hardware.cpus') { |cpus| @appliance_config.hardware.cpus = cpus if cpus > @appliance_config.hardware.cpus }
    end

    # This will merge partitions from multiple appliances.
    def merge_partitions
      partitions = {}

      merge_field('hardware.partitions') do |parts|
        parts.each do |root, partition|
          if partitions.keys.include?(root)
            partitions[root]['size'] = partition['size'] if partitions[root]['size'] < partition['size']
          else
            partitions[root] = partition
          end
        end
      end

      @appliance_config.hardware.partitions = partitions
    end

    def merge_memory
      merge_field('hardware.memory') { |memory| @appliance_config.hardware.memory = memory if memory > @appliance_config.hardware.memory }
    end

    def prepare_os
      merge_field('os.name') { |name| @appliance_config.os.name = name.to_s }
      merge_field('os.version') { |version| @appliance_config.os.version = version.to_s }
      merge_field('os.password') { |password| @appliance_config.os.password = password.to_s }

      @appliance_config.os.password = APPLIANCE_DEFAULTS[:os][:password] if @appliance_config.os.password.nil?
    end

    def prepare_appliances
      @appliance_config.appliances.clear

      @appliance_configs.each do |appliance_config|
        @appliance_config.appliances << appliance_config.name unless appliance_config.name == @appliance_config.name
      end
    end

    def merge_repos
      @appliance_config.repos.clear

      @appliance_configs.each do |appliance_config|
        for repo in appliance_config.repos
          repo['name'] = substitute_repo_parameters(repo['name'])
          ['baseurl', 'mirrorlist'].each do |type|
            repo[type] = substitute_repo_parameters(repo[type]) unless repo[type].nil?
          end

          @appliance_config.repos << repo
        end
      end
    end

    def substitute_repo_parameters(str)
      return if str.nil?
      str.gsub(/#OS_NAME#/, @appliance_config.os.name).gsub(/#OS_VERSION#/, @appliance_config.os.version).gsub(/#ARCH#/, @appliance_config.hardware.arch)
    end

    def merge_packages
      @appliance_config.packages.includes.clear
      @appliance_config.packages.excludes.clear

      @appliance_configs.each do |appliance_config|
        appliance_config.packages.includes.each do |package|
          @appliance_config.packages.includes << package
        end

        appliance_config.packages.excludes.each do |package|
          @appliance_config.packages.excludes << package
        end
      end
    end

    def merge_post_operations
      @appliance_config.post.each_value {|cmds| cmds.clear}

      @appliance_configs.each do |appliance_config|
        appliance_config.post.each do |platform, cmds|
          cmds.each { |cmd| @appliance_config.post[platform] << cmd }
        end
      end
    end

    def merge_field(field, force = false)
      @appliance_configs.each do |appliance_config|
        value = eval("appliance_config.#{field}")
        next if value.nil? and !force
        yield value
      end
    end
  end
end
