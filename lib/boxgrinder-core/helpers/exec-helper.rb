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
require 'rubygems'
require 'open4'

module BoxGrinder
  class InterruptionError < Interrupt
    attr_reader :pid

    def initialize(pid)
      @pid = pid
    end
  end

  class ExecHelper
    def initialize(options = {})
      @log = options[:log] || Logger.new(STDOUT)
    end

    def execute(command, options = {})
      redacted = options[:redacted] || []

      redacted_command = command
      redacted.each { |word| redacted_command = redacted_command.gsub(word, '<REDACTED>') }

      @log.debug "Executing command: '#{redacted_command}'"

      output = ""

      # dirty workaround for ruby segfaults related to logger.rb
      STDOUT.sync = true
      STDERR.sync = true

      begin
        process_pid = nil

        status = Open4::popen4(command) do |pid, stdin, stdout, stderr|
          process_pid = pid
          threads = []

          threads << Thread.new(stdout) do |input_str|
            input_str.each do |l|
              l.chomp!
              l.strip!

              output << "\n#{l}"
              @log.debug l
            end
          end

          threads << Thread.new(stderr) do |input_str|
            input_str.each do |l|
              l.chomp!
              l.strip!

              output << "\n#{l}"
              @log.debug l
            end
          end
          threads.each { |t| t.join }
        end

        raise "process exited with wrong exit status: #{status.exitstatus}" if status.exitstatus != 0

        return output.strip
      rescue Interrupt
        raise InterruptionError.new(process_pid), "Program was interrupted."
      rescue => e
        @log.error e.backtrace.join($/)
        raise "An error occurred while executing command: '#{redacted_command}', #{e.message}"
      end
    end
  end
end
