require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'strongbox'

desc 'Default: run tests.'
task :default => :test

desc 'Test the strongbox gem.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'profile'
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

spec = Gem::Specification.new do |s|
  s.name = "strongbox"
  s.version = Strongbox::VERSION
  s.summary = "Secures ActiveRecord fields with public key encryption."
  s.authors = ["Spike Ilacqua"]
  s.email = "spike@stuff-things.net"
  s.homepage = "http://stuff-things.net/strongbox"
  s.files = FileList["[A-Z]*", "init.rb", "{lib,rails,test}/**/*"]
  s.add_development_dependency 'thoughtbot-shoulda'
end

desc "Generate a gemspec file for GitHub"
task :gemspec do
  File.open("#{spec.name}.gemspec", 'w') do |f|
    f.write spec.to_yaml
  end
end