require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rake/testtask'

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

desc "Generate a gemspec file for GitHub"
task :gemspec do
  $spec = eval(File.read('strongbox.gemspec'))
  $spec.validate
end

desc "Build the gem"
task :build  => :gemspec do
  Gem::Builder.new($spec).build
end
