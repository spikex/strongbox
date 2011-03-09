lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'strongbox'

Gem::Specification.new do |s|
  s.name = "strongbox"
  s.version = Strongbox::VERSION
  s.summary = "Secures ActiveRecord fields with public key encryption."
  s.authors = ["Spike Ilacqua"]
  s.email = "spike@stuff-things.net"
  s.description = <<-EOF
    Strongbox provides Public Key Encryption for ActiveRecord. By using a
    public key sensitive information can be encrypted and stored automatically.
    Once stored a password is required to access the information. dependencies
    are specified in standard Ruby syntax.
  EOF
  s.homepage = "http://stuff-things.net/strongbox"
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- test/*`.split("\n")
  s.add_runtime_dependency 'activerecord'
  s.add_development_dependency 'thoughtbot-shoulda'
  s.add_development_dependency 'sqlite3'
end
