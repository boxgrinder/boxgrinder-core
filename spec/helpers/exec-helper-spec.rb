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

require 'boxgrinder-core/helpers/exec-helper'

module BoxGrinder
  describe ExecHelper do
    before(:each) do
      @helper = ExecHelper.new( :log => Logger.new('/dev/null') )
    end

    it "should fail when command doesn't exists" do
      Open4.should_receive( :popen4 ).with('thisdoesntexists').and_raise('abc')

      proc { @helper.execute("thisdoesntexists") }.should raise_error("An error occurred while executing command: 'thisdoesntexists', abc")
    end

    it "should fail when command exit status != 0" do
      open4 = mock(Open4)
      open4.stub!(:exitstatus).and_return(1)

      Open4.should_receive( :popen4 ).with('abc').and_return(open4)

      proc { @helper.execute("abc") }.should raise_error("An error occurred while executing command: 'abc', process exited with wrong exit status: 1")
    end

    it "should execute the command" do
      open4 = mock(Open4)
      open4.stub!(:exitstatus).and_return(0)

      Open4.should_receive( :popen4 ).with('abc').and_return(open4)

      proc { @helper.execute("abc") }.should_not raise_error
    end

    it "should execute the command and return output" do
      @helper.execute("ls #{File.dirname( __FILE__ )}/../rspec/ls | wc -l").should == "2"
    end

    it "should execute the command and return multi line output" do
      @helper.execute("ls -1 #{File.dirname( __FILE__ )}/../rspec/ls").should == "one\ntwo"
    end
  end
end
