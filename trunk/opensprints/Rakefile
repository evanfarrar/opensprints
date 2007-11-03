require 'rubygems'
require 'rake'

desc 'Default: run unit tests.'
task :default => :test

require 'rake/testtask'

desc 'Run unit tests for OpenSprints.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end

require 'rake/rdoctask'

Rake::RDocTask.new do |rdoc|
  unless File.exists? 'allison'
    `svn co svn://rubyforge.org/var/svn/allison/trunk/allison`
  end
  files = ['lib/**/*.rb', 'doc/**/*.rdoc' ]
  rdoc.rdoc_files.add(files)
  rdoc.title = "OpenSprints Documentation"
  rdoc.template = "allison/allison.rb"
  rdoc.rdoc_dir = 'doc' # rdoc output folder
  rdoc.options << '--line-numbers' << '--inline-source'
end

