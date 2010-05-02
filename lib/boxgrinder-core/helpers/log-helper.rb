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

require 'logger'
require 'boxgrinder-core/defaults'

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

  def trace(progname = nil, & block)
    add(TRACE, nil, progname, & block)
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

    def initialize(log_location = ENV['BG_LOG_LOCATION'])
      threshold     = ENV['BG_LOG_THRESHOLD']
      log_location  ||= DEFAULT_LOCATION[:log]

      unless File.directory?(File.dirname(log_location))
        FileUtils.mkdir_p(File.dirname(log_location))
      end

      threshold = THRESHOLDS[threshold.to_sym] unless threshold.nil?

      @stdout_log         = Logger.new(STDOUT)
      @stdout_log.level   = threshold || Logger::INFO

      @file_log           = Logger.new(log_location, 10, 1024000)
      @file_log.level     = Logger::TRACE
    end

    def method_missing(method_name, * args)
      if THRESHOLDS.keys.include?(method_name)
        @stdout_log.send(method_name, * args)
        @file_log.send(method_name, * args)
      else
        raise NoMethodError
      end
    end
  end
end