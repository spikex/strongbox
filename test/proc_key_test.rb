require 'test/test_helper'

class ProcKeyTest < Test::Unit::TestCase
  context 'With a Proc returning a string for a key pair' do
    setup do
      @password = 'boost facile'
      rebuild_model :key_pair => Proc.new {
        File.read(File.join(FIXTURES_DIR,'keypair.pem'))
      }
      @dummy = Dummy.new
      @dummy.secret = 'Shhhh'
    end

    should_encypted_and_decrypt
  end

  context 'With a Proc returning a key object' do
    setup do
      @password = 'boost facile'
      @private_key = OpenSSL::PKey::RSA.new(2048)
      rebuild_model :key_pair => Proc.new { @private_key }
      @dummy = Dummy.new
      @dummy.secret = 'Shhhh'
    end

    should_encypted_and_decrypt
  end

  context 'With Procs returning public and private key strings' do
    setup do
      @password = 'boost facile'
      @key_pair = File.read(File.join(FIXTURES_DIR,'keypair.pem'))

      rebuild_model :public_key => Proc.new { @key_pair },
                    :private_key => Proc.new { @key_pair } 
      @dummy = Dummy.new
      @dummy.secret = 'Shhhh'
    end

    should_encypted_and_decrypt
  end

  context 'With Procs returning public and private key objects' do
    setup do
      @password = 'boost facile'
      @private_key = OpenSSL::PKey::RSA.new(2048)
      @public_key = @private_key.public_key

      rebuild_model :public_key => Proc.new { @public_key },
                    :private_key => Proc.new { @private_key } 
      @dummy = Dummy.new
      @dummy.secret = 'Shhhh'
    end

    should_encypted_and_decrypt
  end
end
