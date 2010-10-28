# Copyright 2010 Andrew R. Greenwood and Jonathan P. Voss
#
# This file is part of Configuration Repository (CR)
#
# Configuration Repository (CR) is free software: you can redistribute 
# it and/or modify it under the terms of the GNU General Public License 
# as published by the Free Software Foundation, either version 3 of the 
# License, or (at your option) any later version.
#
# Configuration Repository (CR) is distributed in the hope that it will 
# be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with CR. If not, see <http://www.gnu.org/licenses/>.
#

require 'cr/host'

module CRTest

  class CR
    
    class Host < ::CR::Host
      
      # Overwrite process method to bypass attempts to connect to a real device.
      #
      def process
        # set the driver instance variable so that snmp fingerprinting will not
        # occur.
        @driver = 'TESTING'
        super
        return { 'testfile' => ['test contents\r\n'] }
      end # def process
      
    end # class Host
    
  end # class CR

end # module CRTest
