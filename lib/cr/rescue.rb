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

require 'cr/constants'

module CR
  
  module Rescue
    
    def self.catch_fatal(err_object)
        
      puts "#{err_object}"
      exit ARGUMENT_ERROR
      
    end # def self.catch_fatal
    
    def self.catch_host(err_object, host_object)
      
      if err_object.is_a? Host::NonFatalError
          
        CR::log.error "NonFatalError: #{host_object.hostname} - #{err_object} -- skipping"
        
      end # if klass.is_a? Host::NonFatalError
      
      if err_object.is_a? SNMP::RequestTimeout
        
        CR::log.error "SNMP timeout: #{host_object.hostname} -- skipping"
        
      end # if klass.is_a? SNMP::RequestTimeout
      
    end # def self.catch_host
    
  end # module Recsue
  
end # module CR