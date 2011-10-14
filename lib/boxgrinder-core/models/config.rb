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
require 'yaml'
require 'etc'

module BoxGrinder
  class Config < OpenCascade
    def initialize(values = {})
      super({})

      merge!(
          :file => ENV['BG_CONFIG_FILE'] || "#{ENV['HOME']}/.boxgrinder/config",
          :name => 'BoxGrinder Build',
          :platform => :none,
          :delivery => :none,
          :force => false,
          :log_level => :info,
          :backtrace => false,
          :dir => {
              :root => Dir.pwd,
              :build => 'build',
              :cache => '/var/cache/boxgrinder', # required for appliance-creator
              :tmp => '/tmp'
          },
          :os_config => {},
          :platform_config => {},
          :delivery_config => {},
          :additional_plugins => []
      )

      if ENV['BG_CONFIG_FILE']
        raise "You specified empty configuration file path. Please make sure you set correct path for BG_CONFIG_FILE environment variable." if ENV['BG_CONFIG_FILE'].strip.empty?
        raise "Configuration file '#{ENV['BG_CONFIG_FILE']}' couldn't be found. Please make sure you set correct path for BG_CONFIG_FILE environment variable." unless File.exists?(ENV['BG_CONFIG_FILE'])
      end

      deep_merge!(YAML.load_file(self.file)) if File.exists?(self.file)
      merge_with_symbols!(values)

      self.backtrace = true if [:debug, :trace].include?(self.log_level)

      add_user_ids!(self)
    end

    def merge_with_symbols!(values)
      merge!(values.inject({}) { |memo, (k, v)| memo[k.to_sym] = v; memo })
    end

    def deep_merge!(h)
      deep_merge(self, h)
    end

    def deep_merge(first, second)
      second.each_key do |k|
        if first[k.to_sym].is_a?(Hash) and second[k].is_a?(Hash)
          deep_merge(first[k.to_sym], second[k])
        else
          first[k.to_sym] = second[k]
        end
      end if second
    end

    def add_user_ids!(hash)
      user = Etc.getpwnam('root')
      begin
        ['SUDO_USER', 'LOGNAME'].each do |name|
          env = ENV[name]
          if env
            user = Etc.getpwnam(env)
            break
          end
        end
      rescue ArgumentError => e
        @log.debug "Could not find user. Falling back to defaults (#{e.message})."
      end
      [hash.uid = user.uid, hash.gid = user.gid]
    end
  end
end