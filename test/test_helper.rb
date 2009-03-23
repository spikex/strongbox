ROOT       = File.join(File.dirname(__FILE__), '..')
RAILS_ROOT = ROOT
$LOAD_PATH << File.join(ROOT, 'lib')

require 'rubygems'
require 'test/unit'
require 'activerecord'
gem 'thoughtbot-shoulda', ">= 2.9.0"
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
end
