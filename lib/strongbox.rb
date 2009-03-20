require 'openssl'
require 'base64'

module Strongbox

  VERSION = "0.0.1"

  RSA_PKCS1_PADDING	= 1
  RSA_SSLV23_PADDING	= 2
  RSA_NO_PADDING		= 3
  RSA_PKCS1_OAEP_PADDING	= 4
  
  class << self
    def options
      @options ||= {
        :base64 => false,
        :symmetric => :always,
        :padding => RSA_PKCS1_PADDING
      }
    end
    
    def included base #:nodoc:
      base.extend ClassMethods
    end
  end

  class StrongboxError < StandardError #:nodoc:
  end
  
  module ClassMethods
    def encrypt_with_public_key(name, options = {})
      include InstanceMethods
      
      options = options.symbolize_keys.reverse_merge Strongbox.options
      
      unless options[:key_pair] || options[:public_key]
        raise StrongboxError.new("model does not have key_file")
      end
      
      define_method name do
        unless password = self.instance_variable_get("@#{name}_password")
          return "*encrypted*"
        end
        
        ciphertext = read_attribute(name)
        if ciphertext
          ciphertext = Base64.decode64(ciphertext) if options[:base64]
          key_file = options[:key_pair] || options[:private_key]
          private_key = OpenSSL::PKey::RSA.new(File.read(key_file),password)
          if options[:symmetric] == :always
            key_field = options[:key] || "#{name}_key"
            iv_field = options[:iv] || "#{name}_iv"          
            cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
            cipher.decrypt
            cipher.key = private_key.private_decrypt(read_attribute(key_field),options[:padding])
            cipher.iv = private_key.private_decrypt(read_attribute(iv_field),options[:padding])
            plaintext = cipher.update(ciphertext)
            plaintext << cipher.final
          else
            plaintext = private_key.private_decrypt(ciphertext,options[:padding])
          end
        else
          nil
        end
      end
      
      define_method "#{name}=" do | plaintext |
        if !plaintext.blank?
          key_file = options[:key_pair] || options[:public_key]
          # Using a blank password in OpenSSL::PKey::RSA.new prevents reading
          # the private key if the file is a key pair
          public_key = OpenSSL::PKey::RSA.new(File.read(key_file),"")
          if options[:symmetric] == :always
            key_field = options[:key] || "#{name}_key"
            iv_field = options[:iv] || "#{name}_iv"
            cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
            cipher.encrypt
            cipher.key = random_key = cipher.random_key
            cipher.iv = random_iv = cipher.random_iv

            ciphertext = cipher.update(plaintext)
            ciphertext << cipher.final

            write_attribute(key_field,public_key.public_encrypt(random_key,options[:padding]))
            write_attribute(iv_field,public_key.public_encrypt(random_iv,options[:padding]))
          else
            ciphertext = public_key.public_encrypt(plaintext,options[:padding])
          end
          ciphertext =  Base64.encode64(ciphertext) if options[:base64]
          write_attribute(name,ciphertext)
        end
      end
      
      attr_writer "#{name}_password"
    end
  end
  
  module InstanceMethods
    
  end
end

if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, Strongbox)
end

