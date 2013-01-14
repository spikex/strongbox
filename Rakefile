require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rake/testtask'
require 'rdoc/task'

$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'strongbox'

desc 'Default: run tests.'
task :default => :test

desc 'Test the strongbox gem.'
Rake::TestTask.new(:test) do |t|
  t.libs << '.'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the strongbox gem.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = 'Strongbox'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Generate a gemspec file for GitHub"
task :gemspec do
  $spec = eval(File.read('strongbox.gemspec'))
  $spec.validate
end

desc "Build the gem"
task :build  => :gemspec do
  Gem::Builder.new($spec).build
end
