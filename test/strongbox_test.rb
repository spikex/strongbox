# -*- coding: utf-8 -*-
require 'test/test_helper'

class StrongboxTest < Test::Unit::TestCase
  context 'A Class with a secured field' do
    setup do
      @password = 'boost facile'
      rebuild_model :key_pair => File.join(FIXTURES_DIR,'keypair.pem')
    end

    should 'not error when trying to also create a secure field' do
      assert_nothing_raised do
        Dummy.class_eval do
          encrypt_with_public_key :secret
        end
      end
    end

     context 'that is valid' do
       setup do
         @dummy = Dummy.new
         @dummy.secret = 'Shhhh'
         @dummy.in_the_clear = 'Hey you guys!'
       end

       should 'not change unencrypted fields' do
         assert_equal 'Hey you guys!', @dummy.in_the_clear
       end

       should 'return "*encrypted*" when locked'  do
         assert_equal '*encrypted*', @dummy.secret.decrypt
       end

       should 'return secret when unlocked'  do
         assert_equal 'Shhhh', @dummy.secret.decrypt(@password)
       end

       should 'generate and store symmetric encryption key and IV' do
         assert_not_nil @dummy.attributes['secret_key']
         assert_not_nil @dummy.attributes['secret_iv']
       end

       should 'raise on bad password' do
         assert_raises(OpenSSL::PKey::RSAError) do
           @dummy.secret.decrypt('letmein')
         end
       end

       should 'implement to_json' do
        assert_nothing_raised do
          @dummy.secret.to_json
        end
       end

       context 'updating unencrypted fields' do
         setup do
           @dummy.in_the_clear = 'I see you...'
           @dummy.save
         end

         should 'not effect the secret' do
           assert_equal 'Shhhh', @dummy.secret.decrypt(@password)
         end
       end

       context 'updating the secret' do
         setup do
           @dummy.secret = @new_secret = 'Don\'t tell'
           @dummy.save
         end

         should 'update the secret' do
           assert_equal @new_secret, @dummy.secret.decrypt(@password)
         end
       end

       context 'with symmetric encryption disabled' do
         setup do
           rebuild_class(:key_pair => File.join(FIXTURES_DIR,'keypair.pem'),
                         :symmetric => :never)
           @dummy = Dummy.new
           @dummy.secret = 'Shhhh'
         end

         should 'return "*encrypted*" when locked'  do
           assert_equal '*encrypted*', @dummy.secret.decrypt
         end

         should 'return secret when unlocked'  do
           assert_equal 'Shhhh', @dummy.secret.decrypt(@password)
         end

         should 'allow decryption of other strings encrypted with the same key' do
           encrypted_text = File.read(File.join(FIXTURES_DIR,'encrypted'))
           assert_equal 'Setec Astronomy', @dummy.secret.decrypt(@password, encrypted_text)
         end

         should 'not generate and store symmetric encryption key and IV' do
           assert_nil @dummy.attributes['secret_key']
           assert_nil @dummy.attributes['secret_iv']
         end

       end

       context 'with Base64 encoding enabled' do
         setup do
           rebuild_class(:key_pair => File.join(FIXTURES_DIR,'keypair.pem'),
                         :base64 => true)
           @dummy = Dummy.new
           @dummy.secret = 'Shhhh'
         end

         should 'Base64 encode the ciphertext' do
           # Base64 encoded text is limited to the charaters A–Z, a–z, and 0–9,
           # and is padded with 0 to 2 equal-signs
           assert_match /^[0-9A-Za-z+\/]+={0,2}$/, @dummy.attributes['secret']
           assert_match /^[0-9A-Za-z+\/]+={0,2}$/, @dummy.attributes['secret_key']
           assert_match /^[0-9A-Za-z+\/]+={0,2}$/, @dummy.attributes['secret_iv']
         end

         should 'encrypt the data'  do
           assert_not_equal @dummy.attributes['secret'], 'Shhhh'
           assert_equal '*encrypted*', @dummy.secret.decrypt
           assert_equal 'Shhhh', @dummy.secret.decrypt(@password)
         end
       end
     end

     context 'using blowfish cipher instead of AES' do
       setup do
         rebuild_class(:key_pair => File.join(FIXTURES_DIR,'keypair.pem'),
                       :symmetric_cipher => 'bf-cbc')
         @dummy = Dummy.new
         @dummy.secret = 'Shhhh'
       end

       should 'encrypt the data'  do
         assert_not_equal @dummy.attributes['secret'], 'Shhhh'
         assert_equal '*encrypted*', @dummy.secret.decrypt
         assert_equal 'Shhhh', @dummy.secret.decrypt(@password)
       end
     end
  end

  context 'when a public key is not provided' do
    setup do
      rebuild_class
      @dummy = Dummy.new
    end

    should 'raise on encrypt' do
      assert_raises(Strongbox::StrongboxError) do
        @dummy.secret = 'Shhhh'
      end
    end
  end

  context 'when a private key is not provided' do
    setup do
      @password = 'boost facile'
      rebuild_class(:public_key => File.join(FIXTURES_DIR,'keypair.pem'))
      @dummy = Dummy.new(:secret => 'Shhhh')
    end

    should 'raise on decrypt with a password' do
      assert_raises(Strongbox::StrongboxError) do
        @dummy.secret.decrypt(@password)
      end
    end

    should 'return "*encrypted*" when still locked' do
      assert_equal '*encrypted*', @dummy.secret.decrypt
    end
  end

  context "when an unencrypted public key is used" do
     setup do
      rebuild_class(:public_key => generate_key_pair.public_key)
      @dummy = Dummy.new(:secret => 'Shhhh')
     end

    should "encrypt the data"  do
      assert_not_equal @dummy.attributes['secret'], 'Shhhh'
      assert_equal '*encrypted*', @dummy.secret.decrypt
    end
  end

  context "when an unencrypted key pair is used" do
     setup do
      rebuild_class(:key_pair => generate_key_pair)
      @dummy = Dummy.new(:secret => 'Shhhh')
     end

    should "encrypt the data"  do
      assert_not_equal @dummy.attributes['secret'], 'Shhhh'
      assert_equal "Shhhh", @dummy.secret.decrypt('')
    end
  end

  context 'A Class with two secured fields' do
    setup do
      @password = 'boost facile'
      key_pair = File.join(FIXTURES_DIR,'keypair.pem')
      Dummy.class_eval do
        encrypt_with_public_key :secret, :key_pair => key_pair
        encrypt_with_public_key :segreto, :key_pair => key_pair,
                                          :symmetric => :never
      end
    end

    context 'that is valid' do
      setup do
        @dummy = Dummy.new
        @dummy.secret = 'I have a secret...'
        @dummy.segreto = 'Ho un segreto...'
      end

      should 'return "*encrypted*" when the record is locked'  do
        assert_equal '*encrypted*', @dummy.secret.decrypt
        assert_equal '*encrypted*', @dummy.segreto.decrypt
      end

       should 'return the secrets when unlocked'  do
         assert_equal 'I have a secret...', @dummy.secret.decrypt(@password)
         assert_equal 'Ho un segreto...', @dummy.segreto.decrypt(@password)
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
