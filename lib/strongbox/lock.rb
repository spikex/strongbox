module Strongbox
  # The Lock class encrypts and decrypts the protected attribute.  It 
  # automatically encrypts the data when set and decrypts it when the private
  # key password is provided.
  class Lock
      
    def initialize name, instance, options = {}
      @name              = name
      @instance          = instance
      
      @size = nil
      
      options = Strongbox.options.merge(options)
      
      @base64 = options[:base64]
      @public_key = options[:public_key] || options[:key_pair]
      @private_key = options[:private_key] || options[:key_pair]
      @padding = options[:padding]
      @symmetric = options[:symmetric]
      @symmetric_cipher = options[:symmetric_cipher]
      @symmetric_key = options[:symmetric_key] || "#{name}_key"
      @symmetric_iv = options[:symmetric_iv] || "#{name}_iv"
    end
    
    def encrypt plaintext
      unless @public_key
        raise StrongboxError.new("#{@instance.class} model does not have public key_file")
      end
      if !plaintext.blank?
        @size = plaintext.size # For validations
        # Using a blank password in OpenSSL::PKey::RSA.new prevents reading
        # the private key if the file is a key pair
        public_key = OpenSSL::PKey::RSA.new(File.read(@public_key),"")
        if @symmetric == :always
          cipher = OpenSSL::Cipher::Cipher.new(@symmetric_cipher)
          cipher.encrypt
          cipher.key = random_key = cipher.random_key
          cipher.iv = random_iv = cipher.random_iv

          ciphertext = cipher.update(plaintext)
          ciphertext << cipher.final
          encrypted_key = public_key.public_encrypt(random_key,@padding)
          encrypted_iv = public_key.public_encrypt(random_iv,@padding)
          if @base64
            encrypted_key = Base64.encode64(encrypted_key)
            encrypted_iv = Base64.encode64(encrypted_iv)
          end
          @instance[@symmetric_key] = encrypted_key
          @instance[@symmetric_iv] = encrypted_iv
        else
          ciphertext = public_key.public_encrypt(plaintext,@padding)
        end
        ciphertext =  Base64.encode64(ciphertext) if @base64
        @instance[@name] = ciphertext
      end
    end
    
    # Given the private key password decrypts the attribute.  Will raise
    # OpenSSL::PKey::RSAError if the password is wrong.
    
    def decrypt password = ""
      # Given a private key and a nil password OpenSSL::PKey::RSA.new() will
      # *prompt* for a password, we default to an empty string to avoid that.
      ciphertext = @instance[@name]
      return nil if ciphertext.nil?
      return "" if ciphertext.empty?
      
      return "*encrypted*" if password.blank?

      unless @private_key
        raise StrongboxError.new("#{@instance.class} model does not have private key_file")
      end
      
      if ciphertext
        ciphertext = Base64.decode64(ciphertext) if @base64
        private_key = OpenSSL::PKey::RSA.new(File.read(@private_key),password)
        if @symmetric == :always
          random_key = @instance[@symmetric_key]
          random_iv = @instance[@symmetric_iv]
          if @base64
            random_key = Base64.decode64(random_key)
            random_iv = Base64.decode64(random_iv)
          end
          cipher = OpenSSL::Cipher::Cipher.new(@symmetric_cipher)
          cipher.decrypt
          cipher.key = private_key.private_decrypt(random_key,@padding)
          cipher.iv = private_key.private_decrypt(random_iv,@padding)
          plaintext = cipher.update(ciphertext)
          plaintext << cipher.final
        else
          plaintext = private_key.private_decrypt(ciphertext,@padding)
        end
      else
        nil
      end
    end
    
    def to_s
      decrypt
    end
    
    # Needed for validations
    def blank?
      @instance[@name].blank?
    end
    
    def nil?
      @instance[@name].nil?
    end
    
    def size
      @size
    end
  end
end
