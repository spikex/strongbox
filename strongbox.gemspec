# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{strongbox}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Spike Ilacqua"]
  s.date = %q{2009-03-23}
  s.email = %q{spike@stuff-things.net}
  s.files = ["README.textile", "LICENSE", "Rakefile", "init.rb", "lib/strongbox", "lib/strongbox/lock.rb", "lib/strongbox.rb", "rails/init.rb", "test/database.yml", "test/debug.log", "test/fixtures", "test/fixtures/keypair.pem", "test/strongbox_test.rb", "test/test_helper.rb"]
  s.homepage = %q{http://stuff-things.net/strongbox}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Secures ActiveRecord fields with public key encryption.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
  end
end
