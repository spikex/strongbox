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

  context "With dynamic keys, just initialized" do
    setup do
      ActiveRecord::Base.connection.create_table :dummies, :force => true do |table|
        table.string :in_the_clear
        table.binary :secret
        table.binary :secret_key
        table.binary :secret_iv
        table.binary :segreto

        table.string :key_pair
      end
      rebuild_class :public_key => :key_pair,
                    :private_key => :key_pair,
                    :deferred_encryption => true

      Dummy.class_eval do
        attr_accessor :password

        def key_pair
          unless self['key_pair']
            raise if self.password.blank?
            self['key_pair'] = generate_key_pair(self.password)
          end
          self['key_pair']
        end
      end

      @password = 'letmein'
    end

    context 'When just initialized' do
      setup do
        @dummy = Dummy.new
        @dummy.secret = 'Shhhh'
        @dummy.password = @password
      end

      should 'return secret when locked'  do
        assert_equal 'Shhhh', @dummy.secret.decrypt
      end

      should 'return secret when unlocked'  do
        assert_equal 'Shhhh', @dummy.secret.decrypt(@password)
      end
    end

    context 'After saving the model, and then loading it from the database' do
      setup do
        Dummy.create!(:secret => 'Shhhh', :password => @password)
        @dummy = Dummy.first
      end

      should_encypted_and_decrypt
    end

    teardown do
      rebuild_model
    end
  end
end
