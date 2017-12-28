module Strongbox
  if RUBY_VERSION >= '2.4.0'
    class Cipher < OpenSSL::Cipher; end
  else
    class Cipher < OpenSSL::Cipher::Cipher; end
  end
end
