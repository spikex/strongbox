module Strongbox
  # The Lock class encrypts and decrypts the protected attribute.  It
  # automatically encrypts the data when set and decrypts it when the private
  # key password is provided.
  class Lock

    def initialize name, instance, options = {}
      @name              = name
      @instance          = instance

      @size = 0

      options = Strongbox.options.merge(options)

      @base64 = options[:base64]
      @public_key = options[:public_key] || options[:key_pair]
      @private_key = options[:private_key] || options[:key_pair]
      @padding = options[:padding]
      @symmetric = options[:symmetric]
      @symmetric_cipher = options[:symmetric_cipher]
      @symmetric_key = options[:symmetric_key] || "#{name}_key"
      @symmetric_iv = options[:symmetric_iv] || "#{name}_iv"
      @ensure_required_columns = options[:ensure_required_columns]
      @deferred_encryption = options[:deferred_encryption]
    end

    def content plaintext
      @size = plaintext.size unless plaintext.nil? # For validations
      if @deferred_encryption
        @raw_content = plaintext
      else
        encrypt plaintext
      end
    end

    def encrypt!
      encrypt @raw_content
      @raw_content = nil
    end

    def encrypt plaintext
      ensure_required_columns  if @ensure_required_columns
      unless @public_key
        raise StrongboxError.new("#{@instance.class} model does not have public key_file")
      end
      if !plaintext.blank?
        # Using a blank password in OpenSSL::PKey::RSA.new prevents reading
        # the private key if the file is a key pair
        public_key = get_rsa_key(@public_key,"")
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

    def decrypt password = nil, ciphertext = nil
      return @raw_content if @deferred_encryption && @raw_content

      # Given a private key and a nil password OpenSSL::PKey::RSA.new() will
      # *prompt* for a password, we default to an empty string to avoid that.
      ciphertext ||= @instance[@name]
      unless @deferred_encryption
        return nil if ciphertext.nil?
        return "" if ciphertext.empty?
      end

      return "*encrypted*" if password.nil?
      unless @private_key
        raise StrongboxError.new("#{@instance.class} model does not have private key_file")
      end

      if ciphertext
        ciphertext = Base64.decode64(ciphertext) if @base64
        private_key = get_rsa_key(@private_key,password)
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
      @raw_content || decrypt
    end

    def to_json(options = nil)
      to_s
    end

    def as_json(options = nil)
      to_s
    end

    # Needed for validations
    def blank?
      @raw_content.blank? and @instance[@name].blank?
    end

    def nil?
      @raw_content.nil? and @instance[@name].nil?
    end

    def size
      @size
    end

    def length
      @size
    end

  def ensure_required_columns
    columns = [@name.to_s]
    columns += [@symmetric_key, @symmetric_iv] if @symmetric == :always
    columns.each do |column|
      unless @instance.class.column_names.include? column
        raise StrongboxError.new("#{@instance.class} model does not have database column \"#{column}\"")
      end
    end
  end

private
    def get_rsa_key(key,password = '')
      if key.is_a?(Proc)
        key = key.call
      end

      if key.is_a?(Symbol)
        key = @instance.send(key)
      end

      return key if key.is_a?(OpenSSL::PKey::RSA)

      if key.respond_to?(:read)
        key = key.read
      elsif key !~ /^-+BEGIN .* KEY-+$/
        key = File.read(key)
      end
      return OpenSSL::PKey::RSA.new(key,password)
    end
  end
end
