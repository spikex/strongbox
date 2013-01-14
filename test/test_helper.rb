ROOT       = File.join(File.dirname(__FILE__), '..')
RAILS_ROOT = ROOT
$LOAD_PATH << File.join(ROOT, 'lib')

require 'test/unit'
require 'sqlite3'
require 'active_record'
require 'logger'
require 'shoulda'
begin require 'redgreen'; rescue LoadError; end

require 'strongbox'

ENV['RAILS_ENV'] ||= 'test'

FIXTURES_DIR = File.join(File.dirname(__FILE__), "fixtures") 
config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config['test'])


# rebuild_model and rebuild_class are borrowed directly from the Paperclip gem
#
# http://thoughtbot.com/projects/paperclip

# rebuild_model (re)creates a database table for our Dummy model.
# Call this to initial create a model, or to reset the database.

def rebuild_model options = {}
  ActiveRecord::Base.connection.create_table :dummies, :force => true do |table|
    table.string :in_the_clear
    table.binary :secret
    table.binary :secret_key
    table.binary :secret_iv
    table.binary :segreto
  end
  rebuild_class options
end

# rebuild_class creates or replaces the Dummy ActiveRecord Model.
# Call this when changing the options to encrypt_with_public_key

def rebuild_class options = {}
  ActiveRecord::Base.send(:include, Strongbox)
  Object.send(:remove_const, "Dummy") rescue nil
  Object.const_set("Dummy", Class.new(ActiveRecord::Base))
  Dummy.class_eval do
    include Strongbox
    encrypt_with_public_key :secret, options
  end
  Dummy.reset_column_information
end

def assert_has_errors_on(model,attribute)
  # Rails 2.X && Rails 3.X
  assert !model.errors[attribute].empty?
end

def assert_does_not_have_errors_on(model,attribute)
  # Rails 2.X                     Rails 3.X
  assert model.errors[attribute].nil? || model.errors[attribute].empty?
end

def generate_key_pair(password = nil,size = 2048)
  rsa_key = OpenSSL::PKey::RSA.new(size)
  # If no password is provided, don't encrypt the key
  return rsa_key if password.blank?
  cipher =  OpenSSL::Cipher::Cipher.new('des3')
  key_pair = rsa_key.to_pem(cipher,password)
  key_pair << rsa_key.public_key.to_pem
  return key_pair
end

class Test::Unit::TestCase
  def self.should_encypted_and_decrypt
    should 'return "*encrypted*" when locked'  do
      assert_equal '*encrypted*', @dummy.secret.decrypt
    end

    should 'return secret when unlocked'  do
      assert_equal 'Shhhh', @dummy.secret.decrypt(@password)
    end
  end
end
