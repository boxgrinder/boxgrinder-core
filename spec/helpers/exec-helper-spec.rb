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
require 'boxgrinder-core/helpers/exec-helper'

module BoxGrinder
  describe ExecHelper do
    before(:each) do
      @helper = ExecHelper.new(:log => Logger.new('/dev/null'))
      @o4 = (RUBY_PLATFORM =~ /java/ ? IO : Open4)

      @pid = 1234
      @stdin = mock('STDIN')
      @stdout = mock('STDOUT')
      @stderr = mock('STDERR')
    end

    it "should fail when command doesn't exists" do
      @o4.should_receive(:send).with(:popen4, 'thisdoesntexists').and_raise('abc')
      proc { @helper.execute("thisdoesntexists") }.should raise_error("An error occurred while executing command: 'thisdoesntexists', abc")
    end

    if RUBY_PLATFORM =~ /java/
      it "should fail when command exit status != 0 and is on MRI" do
        @stdout.should_receive(:each)
        @stderr.should_receive(:each)
        Process.should_receive(:getpgid)
        Process.should_receive(:waitpid2).with(1234).and_return([1234, OpenCascade.new(:exitstatus => 1)])

        @o4.should_receive(:send).with(:popen4, 'exitstatus').and_return([@pid, @stdin, @stdout, @stderr])

        lambda { @helper.execute("exitstatus") }.should_not raise_error("An error occurred while executing command: 'exitstatus', process exited with wrong exit status: 1")
      end
    else
      it "should fail when command exit status != 0 and is on MRI" do
        @stdout.should_receive(:each)
        @stderr.should_receive(:each)
        Process.should_receive(:getpgid)
        Process.should_receive(:waitpid2).with(1234).and_return([1234, OpenCascade.new(:exitstatus => 1)])

        @o4.should_receive(:send).with(:popen4, 'exitstatus').and_return([@pid, @stdin, @stdout, @stderr])

        lambda { @helper.execute("exitstatus") }.should raise_error("An error occurred while executing command: 'exitstatus', process exited with wrong exit status: 1")
      end
    end

    it "should execute the command" do
      @stdout.should_receive(:each)
      @stderr.should_receive(:each)
      Process.should_receive(:getpgid)
      Process.should_receive(:waitpid2).with(1234).and_return([1234, OpenCascade.new(:exitstatus => 0)])

      @o4.should_receive(:send).with(:popen4, 'abc').and_return([@pid, @stdin, @stdout, @stderr])

      lambda { @helper.execute("abc") }.should_not raise_error
    end

    it "should execute the command and return output" do
      @helper.execute("ls #{File.dirname(__FILE__)}/../rspec/ls | wc -l").should == "2"
    end

    it "should execute the command and return multi line output" do
      @helper.execute("ls -1 #{File.dirname(__FILE__)}/../rspec/ls").should == "one\ntwo"
    end

    it "should redact some words from a command" do
      log = mock('Logger')
      log.should_receive(:debug).with("Executing command: 'ala ma <REDACTED> i jest fajnie'")

      @stdout.should_receive(:each)
      @stderr.should_receive(:each)
      Process.should_receive(:getpgid)
      Process.should_receive(:waitpid2).with(1234).and_return([1234, OpenCascade.new(:exitstatus => 0)])

      @helper = ExecHelper.new(:log => log)
      @o4.should_receive(:send).with(:popen4, "ala ma kota i jest fajnie").and_return([@pid, @stdin, @stdout, @stderr])

      @helper.execute("ala ma kota i jest fajnie", :redacted => ['kota'])
    end
  end
end
