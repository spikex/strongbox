require 'test/test_helper'

class ValidationsTest < Test::Unit::TestCase
  context 'with validations' do
    setup do
      rebuild_model :key_pair => File.join(FIXTURES_DIR,'keypair.pem')
    end

    context 'using validates_presence_of' do
      setup do
        Dummy.send(:validates_presence_of, :secret)
        @valid = Dummy.new(:secret => 'Shhhh')
        @invalid = Dummy.new(:secret => nil)
      end
      
      should 'not have an error on the secret when valid' do
        assert @valid.valid?
        assert_does_not_have_errors_on(@valid,:secret)
      end
      
      should 'have an error on the secret when invalid' do
        assert !@invalid.valid?
        assert_has_errors_on(@invalid,:secret)
      end
    end
    
    context 'using validates_length_of' do
      setup do
        Dummy.send(:validates_length_of,
                   :secret,
                   :in => 5..10,
                   :allow_nil => true,
                   :allow_blank => true
                   )
        @valid = Dummy.new(:secret => 'Shhhh')
        @valid_nil = Dummy.new(:secret => nil)
        @valid_blank = Dummy.new(:secret => '')
        @invalid = Dummy.new(:secret => '1')
      end
      
      should 'not have an error on the secret when in range' do
        assert @valid.valid?
        assert_does_not_have_errors_on(@valid,:secret)
      end
      
      should 'not have an error on the secret when nil' do
        assert @valid_nil.valid?
        assert_does_not_have_errors_on(@valid_nil,:secret)
      end
      
      should 'not have an error on the secret when blank' do
        assert @valid_blank.valid?
        assert_does_not_have_errors_on(@valid_blank,:secret)
      end
      
      should 'have an error on the secret when invalid' do
        assert !@invalid.valid?
        assert_has_errors_on(@invalid,:secret)
      end
    end

        
    if defined?(ActiveModel::Validations)  # Rails 3
      context 'using validates for length' do
        setup do
          Dummy.send(:validates,
                     :secret,
                     :length => {:minimum => 4, :maximum => 16})
          @valid = Dummy.new(:secret => 'Shhhh')
          @out_of_range = [Dummy.new(:secret => 'x' * 3),
                           Dummy.new(:secret => 'x' * 17)]
          @blank = [Dummy.new(:secret => nil),
                    Dummy.new(:secret => '')]
        end
      
        should 'not have an error on the secret when in range' do
          assert @valid.valid?
          assert_does_not_have_errors_on(@valid,:secret)
        end

        should 'have an error on the secret when out of range' do
          @out_of_range.each do |instance|
            assert !instance.valid?
            assert_has_errors_on(instance,:secret)
          end
        end

        should 'have an error on the secret when blank' do
          @blank.each do |instance|
            assert !instance.valid?
            assert_has_errors_on(instance,:secret)
          end
        end
      end
    end
  end

end

