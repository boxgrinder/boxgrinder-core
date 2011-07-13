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
require 'rspec'
require 'boxgrinder-core/helpers/appliance-transformation-helper'

module BoxGrinder
  describe ApplianceTransformationHelper do
    before(:each) do

      @log = LogHelper.new(:level => :trace, :type => :stdout)
      @helper = ApplianceTransformationHelper.new('0.9.0', :log => @log)
    end

    describe ".transform" do
      it "should not transform to the same version" do
        @log.should_not_receive(:debug) # hacky, but does the trick
        @helper.transform('definition', '0.9.0').should == 'definition'
      end

      it "should transform with one pass" do
        @helper.should_receive(:to_0_9_0).with('definition').and_return('new-def')
        @helper.transform('definition', '0.8.0').should == 'new-def'
      end
    end

    describe ".to_0_9_0" do
      it "should remove excludes section" do
        appl = "name: test-appl\nos:\n  name: fedora\n  version: 15\npackages:\n  includes:\n    - @base\n    - emacs\n  excludes:\n    - this-does-nothing"
        out = @helper.to_0_9_0(YAML.load(appl))
        out['packages'].should == ["@base", "emacs"]
        out['excludes'].should == nil
      end
    end
  end
end
