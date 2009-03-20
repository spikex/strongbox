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
       end

       should "have a password method" do
         assert Dummy.new.respond_to?(:secret_password=)
       end
       
       should "return '*encrypted*' when locked"  do
         assert_equal "*encrypted*", @dummy.secret
       end
       
       should "return secret when unlocked"  do
         @dummy.secret_password = 'boost facile'
         assert_equal "Shhhh", @dummy.secret
       end
     end
  end
end

