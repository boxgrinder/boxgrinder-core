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

require 'logger'
require 'fileutils'

Logger.const_set(:TRACE, 0)
Logger.const_set(:DEBUG, 1)
Logger.const_set(:INFO, 2)
Logger.const_set(:WARN, 3)
Logger.const_set(:ERROR, 4)
Logger.const_set(:FATAL, 5)
Logger.const_set(:UNKNOWN, 6)

Logger::SEV_LABEL.insert(0, 'TRACE')

class Logger
  def trace?
    @level <= TRACE
  end

  def trace(progname = nil, &block)
    add(TRACE, nil, progname, &block)
  end
end

module BoxGrinder
  class LogHelper

    THRESHOLDS = {
            :trace  => Logger::TRACE,
            :fatal  => Logger::FATAL,
            :debug  => Logger::DEBUG,
            :error  => Logger::ERROR,
            :warn   => Logger::WARN,
            :info   => Logger::INFO
    }

    def initialize(options = {})
      location      = options[:location] || 'log/boxgrinder.log'
      threshold     = options[:level].nil? ? :info : options[:level].to_sym
      type          = options[:type] || [:stdout, :file]

      unless type.is_a?(Array)
        type = [type.to_s.to_sym]
      end

      threshold = THRESHOLDS[threshold.to_sym] unless threshold.nil?
      formatter = Logger::Formatter.new

      if type.include?(:file)
        FileUtils.mkdir_p(File.dirname(location))

        @file_log             = Logger.new(location, 10, 1024000)
        @file_log.level       = Logger::TRACE
        @file_log.formatter   = formatter
      end

      if type.include?(:stdout)
        @stdout_log           = Logger.new(STDOUT.dup)
        @stdout_log.level     = threshold || Logger::INFO
        @stdout_log.formatter = formatter
      end
    end

    def write( msg )
      @stdout_log.trace( msg.chomp.strip ) unless @stdout_log.nil?
      @file_log.trace( msg.chomp.strip ) unless @file_log.nil?
    end

    def method_missing(method_name, *args)
      @stdout_log.send(method_name, *args) unless @stdout_log.nil?
      @file_log.send(method_name, *args) unless @file_log.nil?
    end
  end

  attr_accessor :file_log
  attr_accessor :stdout_log
end
