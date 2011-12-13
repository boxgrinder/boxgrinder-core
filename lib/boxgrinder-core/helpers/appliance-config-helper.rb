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

require 'boxgrinder-core/errors'
require 'set'

module BoxGrinder
  class ApplianceConfigHelper

    VAR_SUBSTITUTION_MAX_DEPTH = 20

    def initialize(appliance_configs)
      @appliance_configs = appliance_configs.reverse
    end

    def merge(appliance_config)
      @appliance_config = appliance_config

      prepare_os
      prepare_appliances

      merge_variables
      merge_hardware
      merge_repos
      merge_default_repos
      merge_packages
      merge_files
      merge_post_operations
      substitute_variables

      @appliance_config
    end

    def merge_default_repos
      @appliance_config.default_repos = true

      @appliance_configs.each do |appliance_config|
        if appliance_config.default_repos == false
          @appliance_config.default_repos = false
          break
        end
      end
    end

    def merge_variables
      @appliance_config.variables = {} if @appliance_config.variables.nil?
      @appliance_configs.each do |appliance_config|
        appliance_config.variables.each do |var, val|
          @appliance_config.variables[var] = val
        end
      end

      @appliance_config.variables["OS_NAME"] = @appliance_config.os.name
      @appliance_config.variables["OS_VERSION"] = @appliance_config.os.version
      @appliance_config.variables["ARCH"] = @appliance_config.hardware.arch
      @appliance_config.variables["BASE_ARCH"] = @appliance_config.hardware.base_arch

      resolve
    end

    def resolve(resolve_stack = nil, resolved_set = Set.new())
      if resolve_stack.nil?
        @appliance_config.variables.keys.each { |var| resolve([var], resolved_set) }
      else
        var = resolve_stack.last
        refs = @appliance_config.variables.keys.delete_if { |k|
          @appliance_config.variables[k].nil? ||
              @appliance_config.variables[k].index("##{k}#").nil? ||
              resolve_stack.index(k).nil?
        }
        refs.each do |ref|
          resolve(Array.new(resolve_stack).push(ref), resolved_set) unless resolved_set.include?(ref)
          while @appliance_config.variables[var].include? "##{ref}#" do
            @appliance_config.variables[var].gsub!("##{ref}#", @appliance_config.variables[ref])
          end
        end
        resolved_set << var
      end
    end

    # Get all leaf text values in the appliance definition, then substitute any
    # variable values.
    def substitute_variables
      @appliance_config.all_values.each do |value|
        substitute(value.clone, value, 0)
      end
    end

    # Replace variables with values. This will occur recursively upto a limited
    # depth if the resolved values themselves contain variables.
    def substitute(init, value, depth)
      if depth > VAR_SUBSTITUTION_MAX_DEPTH
        raise SystemStackError, "Maximal recursive depth (#{VAR_SUBSTITUTION_MAX_DEPTH})
          reached for resolving variable #{init}, reached #{value} before stopping."
      end
      original = value.clone
      value.gsub!(/(#(.*?)#)+?/) do
       # 1. Match pre-defined variable, or variable defined in appliance definition.
       next @appliance_config.variables[$2] if @appliance_config.variables.has_key?($2)
       # 2. Match from environment variables.
       next ENV[$2] unless ENV[$2].nil?
       # 3. No match, replace the original string.
       $1
      end
      substitute(init, value, depth+1) unless original == value
    end

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

            unless partition['type'].nil?
              partitions[root].delete('options') if partitions[root]['type'] != partition['type']
              partitions[root]['type'] = partition['type']
            else
              partitions[root]['type'] = @appliance_config.default_filesystem_type
            end
          else
            partitions[root] = {}
            partitions[root]['size'] = partition['size']

            unless partition['type'].nil?
              partitions[root]['type'] = partition['type']
            else
              partitions[root]['type'] = @appliance_config.default_filesystem_type
            end
          end

          partitions[root]['passphrase'] = partition['passphrase'] unless partition['passphrase'].nil?
          partitions[root]['options'] = partition['options'] unless partition['options'].nil?
        end
      end

      # https://bugzilla.redhat.com/show_bug.cgi?id=466275
      partitions['/boot'] = {'type' => 'ext3', 'size' => 0.1} if partitions['/boot'].nil? and (@appliance_config.os.name == 'sl' or @appliance_config.os.name == 'centos' or @appliance_config.os.name == 'rhel') and @appliance_config.os.version == '5'

      @appliance_config.hardware.partitions = partitions
    end

    def merge_memory
      merge_field('hardware.memory') { |memory| @appliance_config.hardware.memory = memory if memory > @appliance_config.hardware.memory }
    end

    def prepare_os
      merge_field('os.name') { |name| @appliance_config.os.name = name.to_s }
      merge_field('os.version') { |version| @appliance_config.os.version = version.to_s }
      merge_field('os.password') { |password| @appliance_config.os.password = password.to_s }
      merge_field('os.pae') { |pae| @appliance_config.os.pae = false unless pae }

      @appliance_config.os.password = 'boxgrinder' if @appliance_config.os.password.nil?
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
        appliance_config.repos.each do |repo|
          @appliance_config.repos << repo
        end
      end
    end

    def merge_packages
      @appliance_config.packages.clear

      @appliance_configs.each do |appliance_config|
        appliance_config.packages.each do |package|
          @appliance_config.packages << package
        end
      end
    end

    # [BGBUILD-276] Import files into appliance via appliance definition file (Files section)
    # https://issues.jboss.org/browse/BGBUILD-276
    def merge_files
      @appliance_config.files.each_value { |dirs| dirs.clear }

      included = []

      @appliance_configs.each do |appliance_config|
        next if included.include?(appliance_config)
        appliance_config.files.each do |dir, files|
          @appliance_config.files[dir] = [] if @appliance_config.files[dir].nil?
          files.each { |f| @appliance_config.files[dir] << f }
        end
        included << appliance_config
      end
    end

    def merge_post_operations
      @appliance_config.post.each_value { |cmds| cmds.clear }

      included = []

      @appliance_configs.each do |appliance_config|
        next if included.include?(appliance_config)
        appliance_config.post.each do |platform, cmds|
          @appliance_config.post[platform] = [] if @appliance_config.post[platform].nil?
          cmds.each { |cmd| @appliance_config.post[platform] << cmd }
        end
        included << appliance_config
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
