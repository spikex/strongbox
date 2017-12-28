require 'test/test_helper'

class MissingAttribuesTest < Test::Unit::TestCase
  context 'A Class with a secured field without a matching database column' do
    setup do
      ActiveRecord::Base.connection.create_table :dummies, :force => true do |table|
        table.string :in_the_clear
      end
      rebuild_class {}
    end

    should 'raise' do
      assert_raise(Strongbox::StrongboxError) do
        Dummy.class_eval do
          encrypt_with_public_key :secret, :key_pair =>
            File.join(FIXTURES_DIR,'keypair.pem')
        end
        @dummy = Dummy.new
        @dummy.secret = 'Shhhh'
      end
    end

    teardown do
      rebuild_model
    end
  end

  context 'A Class with a secured field missing symmetric database columns' do
    setup do
      ActiveRecord::Base.connection.create_table :dummies, :force => true do |table|
        table.string :in_the_clear
        table.string :secret
      end
      rebuild_class {}
    end

    should 'raise' do
      assert_raise(Strongbox::StrongboxError) do
        Dummy.class_eval do
          encrypt_with_public_key :secret, :key_pair =>
            File.join(FIXTURES_DIR,'keypair.pem')
        end
        @dummy = Dummy.new
        @dummy.secret = 'Shhhh'
      end
    end

    teardown do
      rebuild_model
    end
  end

  context 'A Class with a secured field without a matching database column told not to check columns' do
    setup do
      ActiveRecord::Base.connection.create_table :dummies, :force => true do |table|
        table.string :in_the_clear
      end
      rebuild_class {}
    end

    should 'not raise' do
      assert_nothing_raised Strongbox::StrongboxError do
        Dummy.class_eval do
          def []=(_attr_name, _value)
            # Stub to prevent ActiveModel::MissingAttributeError error
          end

          encrypt_with_public_key(:secret,
                                  :key_pair => File.join(FIXTURES_DIR,'keypair.pem'),
                                  :ensure_required_columns => false)
        end
        @dummy = Dummy.new
        @dummy.secret = 'Shhhh'
      end
    end

    teardown do
      rebuild_model
    end
  end
end
