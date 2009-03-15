$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'test/unit'
require 'activerecord'
require 'strongbox'
gem 'thoughtbot-shoulda', ">= 2.9.0"
require 'shoulda'
begin require 'redgreen'; rescue LoadError; end
