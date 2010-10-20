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

require 'cr/dns'
require 'cr/host'
require 'cr/log'
require 'cr/options' # TODO - rename class within options?
require 'cr/parse'
require 'cr/repository'

class CR
  
  extend  CommandLine
  include Parsing
  
  attr_accessor :username, :password
  attr_reader   :blacklist, :hosts, :repository
  
  def initialize(options = {}) 
    
    @blacklist    = options[:blacklist] || [] # array of blacklisted hostnames
    @username     = options[:username]
    @password     = options[:password]
    @hosts        = []
    @log          = options[:log]          || _initialize_log
    @regex        = options[:regex]        || //
    @snmp_options = options[:snmp_options] || {}
    
    _initialize_repository(options[:repository], @regex, :git)
    _validate_blacklist
    
  end # def initialize
  
  def add_host(hostobj)
    
    raise "Argument not CR::Host object" unless hostobj.is_a?(CR::Host)
    
    case 
    
      when ! hostobj.hostname.match(@regex)
        @log.debug "Ignoring host (Regex): #{hostobj.hostname}"
    
      when @blacklist.include?(hostobj.hostname)
        @log.info "Ignoring host (Blacklist): #{hostobj.hostname}"
        
      when @hosts.include?(hostobj)
        @log.debug "Ignoring host (Duplicate): #{hostobj.hostname}"
        
      else
        @log.info "Adding host: #{hostobj.hostname}"
        
        hostobj.add_observer(@repository)
        
        @hosts << hostobj
        
    end # case
    
  end # def add_host
  
  # Adds a domain of hosts via AXFR request for an argument specified in
  # host string format.
  #
  def add_domain_string(host_string, snmp_options = {})
    
    # TODO Refactor this with add_host_string
    if host_string.match(/file:(.*)/)
      
      import_file $1, :domain
      
    else
    
      options = { :username     => @username,
                  :password     => @password,
                  :snmp_options => snmp_options,
                  :log          => @log }
      
      options = options.merge parse_host_string(host_string, options)
      
      DNS.instance_variable_set(:@log, @log)
      
      DNS.axfr(options[:hostname]).each do |hostname|
        
        options = options.merge(:hostname => hostname)
        
        add_host CR::Host.new(options)
        
      end # DNS.axfr
    
    end # if
    
  end # def add_domain_string
  
  # Adds a host specified in host string format
  #
  def add_host_string(host_string, snmp_options = {})
    
    if host_string.match(/file:(.*)/)
      
      import_file $1, :host
      
    else
    
      options = { :username     => @username,
                  :password     => @password, 
                  :snmp_options => snmp_options,
                  :log          => @log }
      
      options = options.merge parse_host_string(host_string, options)
        
      add_host CR::Host.new(options)
    
    end # if host_string.match
    
  end # def add_host_string

  # Deletes a host. Argument can be any CR::Host comparable. I.e. hostname
  # or Host object.
  #
  def delete_host!(host)
    
    @log.info "Removed host: #{host}" if @hosts.delete(host)
    
  end # delete_host!
  
  # Imports a blacklist txt file with a hostname per line
  #
  def import_blacklist(filename)
    
    parse_txt_file(filename).each do |host_string|
      @blacklist.push(host_string[0]) unless @blacklist.include?(host_string)
    end
    
  end # def import_blacklist
  
  # Imports supported file types (CSV or TXT). Type specifies either a 
  # :domain or :host
  #
  def import_file(filename, type)
   
    parse_file(filename, @snmp_options).each do |host_string, options|
    
      type == :domain ? add_domain_string(host_string, options) :
                        add_host_string(host_string, options)
    
    end # parse_file
    
  end # def import_file
  
  # Processes all hosts and commits changes to the database. A commit
  # message can be given or left nil to use the default.
  #
  def process_all(commit_msg = nil)
    
    commit_msg = "CR Commit: Processed #{@hosts.size} hosts" if commit_msg.nil?
    
    @hosts.each{ |host| host.process }
    @repository.commit_all(commit_msg) if @repository.changed?
    
  end # def process_all
  
  private
  
  # Initializes CR::Repository object
  #
  def _initialize_repository(directory, regex, type)
    
    @repository = Repository.new( :directory => directory,
                                  :log       => @log,
                                  :regex     => regex,
                                  :type      => type )
                                  
  end # def _initialize_repository
  
  # Validates a blacklist. If a user supplied a string during object creation
  # it is taken as a filename and passed to #import_blacklist. Otherwise an
  # array of hostnames supplied is used.
  #
  def _validate_blacklist
    
    # TODO fix the juggling of @blacklist variable?
    if @blacklist.is_a?(String)
      
      file       = @blacklist
      @blacklist = []
      
      import_blacklist(file)
      
    end # if @blacklist.is_a?(String)
    
    raise "Blacklist must be an array or filename" unless @blacklist.is_a?(Array)
    
  end # def _validate_blacklist
  
end # class CR