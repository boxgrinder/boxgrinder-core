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
require 'boxgrinder-core/models/appliance-config'

module BoxGrinder
  describe ApplianceConfig do
    it "should generate valid build path including version and release" do
      appliance_config = ApplianceConfig.new
      appliance_config.os.name = 'fedora'
      appliance_config.os.version = '15'
      appliance_config.hardware.arch = 'x86_64'
      appliance_config.name = 'testing'
      
      appliance_config.initialize_paths

      appliance_config.path.build.should == 'build/appliances/x86_64/fedora/15/testing/1.0'
    end
  end
end
