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
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
#

require 'rubygems'
require 'rake'
require 'rake/clean'
require 'lib/core'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  
  test.libs   << 'test'
  test.pattern = ['test/tc_*.rb', 'test/vcs/tc_*']
  test.verbose = true
  
end # Rake::TestTask.new

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = "ConfigurationRepository #{CR::VERSION}"
  rdoc.main     = 'README.rdoc'
  rdoc.rdoc_files.include('*.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
  
end # Rake::RDocTask.new

desc "Look for TODO and FIXME tags in the code"
task :todo do
  
  def egrep(pattern)
    
    Dir['**/*.rb'].each do |filename|
      
      # ignore todo/fixme comments in this file
      next if filename == 'Rakefile.rb' 
      
      count = 0
      
      open(filename) do |file|
        
        while line = file.gets
          
          count += 1
          
          if line =~ pattern
            puts "#{filename}:#{count}:#{line}"
          end # if
          
        end # while
        
      end # open
      
    end # Dir
    
  end # def egrep
  
  egrep /(FIXME|TODO|TBD)/
  
end # task :todo

desc "Open an irb session preloaded with this library"
task :console do
  
  sh "irb -rubygems -I lib -r core.rb"

end # task :console
