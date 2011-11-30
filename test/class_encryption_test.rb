require 'test/test_helper'

class ClassEncryptionTest < Test::Unit::TestCase
  context 'A Class with class_encryption enabled' do
    setup do
      rebuild_model :key_pair => File.join(FIXTURES_DIR,'keypair.pem')
      @password = 'boost facile'
      key_pair = File.join(FIXTURES_DIR,'keypair.pem')
      Dummy.class_eval do
        encrypt_with_public_key :segreto, :key_pair => key_pair, :encryption => :class, :symmetric => :never
      end
      @dummy = Dummy.new
      @dummy.segreto = 'I have a segreto...'
    end

    should 'not change class of "segreto"' do
      assert_kind_of String, @dummy.segreto
    end

    should 'not automatically encrypt the segreto' do
      assert_equal 'I have a segreto...', @dummy.segreto
    end

    should 'encrypt the field' do
      @dummy.encrypt!
      assert @dummy.locked?, 'Not locked'
      assert_not_equal 'I have a segreto...', @dummy.segreto
    end

    should 'decrypt the field' do
      @dummy.encrypt!
      @dummy.decrypt!(@password)
      assert_equal 'I have a segreto...', @dummy.segreto
    end
  end
end
