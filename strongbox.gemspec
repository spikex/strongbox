--- !ruby/object:Gem::Specification 
name: strongbox
version: !ruby/object:Gem::Version 
  version: 0.1.3
platform: ruby
authors: 
- Spike Ilacqua
autorequire: 
bindir: bin
cert_chain: []

date: 2009-04-16 00:00:00 -06:00
default_executable: 
dependencies: 
- !ruby/object:Gem::Dependency 
  name: thoughtbot-shoulda
  type: :development
  version_requirement: 
  version_requirements: !ruby/object:Gem::Requirement 
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "0"
    version: 
description: 
email: spike@stuff-things.net
executables: []

extensions: []

extra_rdoc_files: []

files: 
- LICENSE
- Rakefile
- README.textile
- init.rb
- lib/strongbox
- lib/strongbox/lock.rb
- lib/strongbox.rb
- rails/init.rb
- test/database.yml
- test/fixtures
- test/fixtures/keypair.pem
- test/strongbox_test.rb
- test/test_helper.rb
has_rdoc: false
homepage: http://stuff-things.net/strongbox
post_install_message: 
rdoc_options: []

require_paths: 
- lib
required_ruby_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
required_rubygems_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
requirements: []

rubyforge_project: 
rubygems_version: 1.3.1
signing_key: 
specification_version: 2
summary: Secures ActiveRecord fields with public key encryption.
test_files: []

