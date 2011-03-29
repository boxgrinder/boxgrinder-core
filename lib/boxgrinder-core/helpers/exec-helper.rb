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
require 'open4' unless RUBY_PLATFORM =~ /java/

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
        pid, stdin, stdout, stderr = (RUBY_PLATFORM =~ /java/ ? IO : Open4).send(:popen4, command)
        threads = []

        threads << Thread.new(stdout) do |out|
          out.each do |l|
            l.chomp!
            l.strip!

            output << "\n#{l}"
            @log.debug l
          end
        end

        threads << Thread.new(stderr) do |err|
          err.each do |l|
            l.chomp!
            l.strip!

            output << "\n#{l}"
            @log.debug l
          end
        end

        threads.each { |t| t.join }

        # Assume the process exited cleanly, which can cause some bad behaviour, but I don't see better way
        # to get reliable status for processes both on MRI and JRuby
        #
        # http://jira.codehaus.org/browse/JRUBY-5673
        status = OpenCascade.new(:exitstatus => 0)
        
        fakepid, status = Process.waitpid2(pid) if process_alive?(pid)

        raise "process exited with wrong exit status: #{status.exitstatus}" if !(RUBY_PLATFORM =~ /java/) and status.exitstatus != 0

        return output.strip
      rescue Interrupt
        raise InterruptionError.new(pid), "Program was interrupted."
      rescue => e
        @log.error e.backtrace.join($/)
        raise "An error occurred while executing command: '#{redacted_command}', #{e.message}"
      end
    end

    def process_alive?(pid)
      begin
        Process.getpgid(pid)
        true
      rescue Errno::ESRCH
        false
      end
    end
  end
end
