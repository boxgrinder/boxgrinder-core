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
require 'open3'

module BoxGrinder
  class ExecHelper
    def initialize( options = {} )
      @log = options[:log] || Logger.new(STDOUT)
    end

    def execute( command )
      @log.debug "Executing command: '#{command}'"

      output = ""

      Open3.popen3( command ) do |stdin, stdout, stderr|
        threads = []

        threads << Thread.new(stdout) do |input_str|
          input_str.each do |l|
            output << l
            @log.debug l.chomp.strip
          end
        end
        
        threads << Thread.new(stderr) do |input_str|
          input_str.each do |l|
            output << l
            @log.debug l.chomp.strip
          end
        end
        threads.each{|t|t.join}
      end

      raise "An error occurred executing command: '#{command}'" if $?.to_i != 0

      output
    end
  end
end