require 'test/test_helper'

class StrongboxTest < Test::Unit::TestCase
  context "A Class with a secured field" do
    setup do
      rebuild_model :key_pair => File.join(FIXTURES_DIR,'keypair.pem') 
    end

    should "not error when trying to also create a secure field" do
      assert_nothing_raised do
        Dummy.class_eval do
          encrypt_with_public_key :secret,
                                  :key_pair => File.join(FIXTURES_DIR,'keypair.pem')
        end
      end
    end
     
     context "that is valid" do
       setup do
         @dummy = Dummy.new
         @dummy.secret = 'Shhhh'
         @dummy.in_the_clear = 'Hey you guys!'
       end
       
       should "not change unencrypted fields" do
         assert_equal 'Hey you guys!', @dummy.in_the_clear
       end
       
       should "return '*encrypted*' when locked"  do
         assert_equal "*encrypted*", @dummy.secret.decrypt
       end
       
       should "return secret when unlocked"  do
         assert_equal "Shhhh", @dummy.secret.decrypt('boost facile')
       end
       
       should "generate and store symmetric encryption key and IV" do
         assert_not_nil @dummy.attributes['secret_key']
         assert_not_nil @dummy.attributes['secret_iv']
       end
       
       should "raise on bad password" do
         assert_raises(OpenSSL::PKey::RSAError) do
           @dummy.secret.decrypt('letmein')
         end
       end

       context "with symmetric encryption disabled" do
         setup do
           rebuild_class(:key_pair => File.join(FIXTURES_DIR,'keypair.pem'),
                         :symmetric => :never)
           @dummy = Dummy.new
           @dummy.secret = 'Shhhh'
         end
         
         should "return '*encrypted*' when locked"  do
           assert_equal "*encrypted*", @dummy.secret.decrypt
         end
         
         should "return secret when unlocked"  do
           assert_equal "Shhhh", @dummy.secret.decrypt('boost facile')
         end
         
         should "not generate and store symmetric encryption key and IV" do
           assert_nil @dummy.attributes['secret_key']
           assert_nil @dummy.attributes['secret_iv']
         end

       end
       
       context "with Base64 encoding enabled" do
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
         end
       end
     end
     
     context "using blowfish cipher instead of AES" do
       setup do
         rebuild_class(:key_pair => File.join(FIXTURES_DIR,'keypair.pem'),
                       :symmetric_cipher => 'bf-cbc')
         @dummy = Dummy.new
         @dummy.secret = 'Shhhh'
       end
       
       should "encrypt the data"  do
         assert_not_equal @dummy.attributes['secret'], 'Shhhh'
         assert_equal "*encrypted*", @dummy.secret.decrypt
         assert_equal "Shhhh", @dummy.secret.decrypt('boost facile')
       end
     end
  end
   
  context "when a key_pair is not provided" do
    setup do
      rebuild_class
      @dummy = Dummy.new
    end

    should "raise on encrypt" do
      assert_raises(Strongbox::StrongboxError) do
        @dummy.secret = 'Shhhh'
      end
    end
    
    should "raise on decrypt with a password" do
      assert_raises(Strongbox::StrongboxError) do
        @dummy.secret.decrypt('boost facile')
      end
    end
    
    should "return '*encrypted*' when still locked" do
      assert_equal "*encrypted*", @dummy.secret.decrypt
    end
  end
end

