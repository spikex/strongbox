# -*- coding: utf-8 -*-
require 'test/test_helper'

class StrongboxMultiplyTest < Test::Unit::TestCase
  context 'A Class with two secured fields' do
    setup do
      @password = 'boost facile'
      key_pair = File.join(FIXTURES_DIR,'keypair.pem')
      Dummy.class_eval do
        encrypt_with_public_key :secret, :segreto, :key_pair => key_pair
      end
    end

    context 'that is valid' do
      setup do
        @dummy = Dummy.new
        @dummy.secret = 'I have a secret...'
      end

      should 'return "*encrypted*" when the record is locked'  do
        assert_equal '*encrypted*', @dummy.secret.decrypt
      end

       should 'return the secrets when unlocked'  do
         assert_equal 'I have a secret...', @dummy.secret.decrypt(@password)
       end

    end
  end

  context 'Using strings for keys' do
    setup do
      @password = 'boost facile'
      key_pair = File.read(File.join(FIXTURES_DIR,'keypair.pem'))
      public_key = OpenSSL::PKey::RSA.new(key_pair,"")
      private_key = OpenSSL::PKey::RSA.new(key_pair,@password)
      Dummy.class_eval do
        encrypt_with_public_key :secret, :public_key => public_key, :private_key => private_key
      end
      @dummy = Dummy.new
      @dummy.secret = 'Shhhh'
    end

    should 'return "*encrypted*" when locked'  do
      assert_equal '*encrypted*', @dummy.secret.decrypt
    end

    should 'return secret when unlocked'  do
      assert_equal 'Shhhh', @dummy.secret.decrypt(@password)
    end
  end
end
