require 'test/test_helper'

class MethodKeyTest < Test::Unit::TestCase
  context 'With an attribute containing a string for the key pair' do
    setup do
      @password = 'boost facile'
      rebuild_model :key_pair => :key_pair_attribute
      Dummy.class_eval do
        attr_accessor :key_pair_attribute
      end

      @dummy = Dummy.new
      @dummy.key_pair_attribute = File.read(File.join(FIXTURES_DIR,'keypair.pem'))
      @dummy.secret = 'Shhhh'
    end

    should_encypted_and_decrypt
  end

  context 'With a methods returning the key pair' do
    setup do
      @password = 'boost facile'
      rebuild_model :key_pair => :key_pair_method
      Dummy.class_eval do
        def key_pair_method
          File.read(File.join(FIXTURES_DIR,'keypair.pem'))
        end
      end

      @dummy = Dummy.new
      @dummy.secret = 'Shhhh'
    end

    should_encypted_and_decrypt
  end

  context 'With attributes containing strings for the keys' do
    setup do
      @password = 'boost facile'
      rsa_key = OpenSSL::PKey::RSA.new(2048)
      cipher =  OpenSSL::Cipher::Cipher.new('des3')
      rebuild_model :public_key => :public_key_attribute,
                    :private_key => :private_key_attribute
      Dummy.class_eval do
        attr_accessor :public_key_attribute, :private_key_attribute
      end
      @dummy = Dummy.new
      @dummy.public_key_attribute = rsa_key.public_key.to_pem
      @dummy.private_key_attribute = rsa_key.to_pem(cipher,@password)
      @dummy.secret = 'Shhhh'
    end

    should_encypted_and_decrypt
  end

  context 'With methods returning the keys' do
    setup do
      @password = 'boost facile'
      rebuild_model :public_key => :public_key_method,
                    :private_key => :private_key_method
      Dummy.class_eval do
        def public_key_method
          File.read(File.join(FIXTURES_DIR,'keypair.pem'))
        end

        def private_key_method
          File.read(File.join(FIXTURES_DIR,'keypair.pem'))
        end
      end

      @dummy = Dummy.new
      @dummy.secret = 'Shhhh'
    end

    should_encypted_and_decrypt
  end
end
