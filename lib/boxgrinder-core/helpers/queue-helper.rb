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

module BoxGrinder
  class QueueHelper
    def initialize(options = {})
      @log = options[:log]  || Logger.new(STDOUT)
    end

    def client(opts = {})
      begin
        require 'rubygems'
        require 'torquebox-messaging-client'
      rescue
        @log.error "Couldn't load TorqueBox messaging client."
        return nil
      end

      host = opts[:host] || 'localhost'
      port = opts[:port] || 1099

      naming_provider_url = "jnp://#{host}:#{port}/"

      @log.trace "Creating messaging client..."

      ret_val = TorqueBox::Messaging::Client.connect(:naming_provider_url => naming_provider_url ) do |client|
        yield client
      end

      @log.trace "Messaging client closed."

      ret_val
    end
  end
end