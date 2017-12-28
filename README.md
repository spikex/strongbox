# Strongbox

Strongbox provides [Public Key
Encryption](http://en.wikipedia.org/wiki/Public-key_cryptography) for
ActiveRecord. By using a public key, sensitive information can be
encrypted and stored automatically. Once stored a password is required
to access the information.

Because the largest amount of data that can practically be encrypted
with a public key is 245 bytes, by default Strongbox uses a two layer
approach. First it encrypts the attribute using symmetric encryption
with a randomly generated key and initialization vector (IV) (which
can just be thought of as a second key), then it encrypts those with
the public key.

Strongbox stores the encrypted attribute in a database column by the
same name, i.e. if you tell Strongbox to encrypt "secret" then it will
be store in `secret` in the database, just as the unencrypted
attribute would be. If symmetric encryption is used (the default) two
additional columns `secret_key` and `secret_iv` are needed as well.

The attribute is automatically encrypted simply by setting it:

```ruby
user.secret = "Shhhhhhh..."
```

and decrypted by calling the `decrypt` method with the private key password.

```ruby
plain_text = user.secret.decrypt 'letmein'
```

## Environment

Strongbox is tested against Rails 2.3 and 3.x using Ruby 1.8.7, 1.9.2,
and 1.9.3.

## Installation

Include the gem in your Gemfile:

```ruby
gem "strongbox"
```

Still using 2.x without a Gemfile? Put the following in
`config/environment.rb`:

```ruby
config.gem "strongbox"
```

## Quick Start

In your model:

```ruby
class User < ActiveRecord::Base
  encrypt_with_public_key :secret,
    :key_pair => Rails.root.join('config','keypair.pem')
end
```
  
In your migrations:

```ruby
class AddSecretColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :secret, :binary
    add_column :users, :secret_key, :binary
    add_column :users, :secret_iv, :binary
  end
end
```
  
Generate a key pair:

(Choose a strong password.)

```shell
openssl genrsa -des3 -out config/private.pem 2048
openssl rsa -in config/private.pem -out config/public.pem -outform PEM -pubout
cat config/private.pem  config/public.pem >> config/keypair.pem
```

In your views and forms you don't need to do anything special to
encrypt data. To decrypt call:

```ruby
user.secret.decrypt 'password'
```

## Usage

The `encrypt_with_public_key` method sets up the attribute it's called
on for automatic encryption.  It's simplest form is:

```ruby
class User < ActiveRecord::Base
  encrypt_with_public_key :secret,
    :key_pair => Rails.root.join('config','keypair.pem')
end
```

Which will encrypt the attribute `secret`. The attribute will be
encrypted using symmetric encryption with an automatically generated
key and IV encrypted using the public key. This requires three columns
in the database `secret`, `secret_key`, and `secret_iv` (see below).

Options to `encrypt_with_public_key` are:

* `:public_key` - Public key. Overrides :key_pair. See Key Formats below.

* `:private_key` - Private key. Overrides :key_pair.

* `:key_pair` - Key pair, containing both the public and private keys.

* `:symmetric` `:always`/`:never` - Encrypt the date using symmetric encryption. The public key is used to encrypt an automatically generated key and IV. This allows for large amounts of data to be encrypted. The size of data that can be encrypted directly with the public is limit to key size (in bytes) - 11. So a 2048 key can encrypt *245 bytes*. Defaults to `:always`.

* `:symmetric_cipher` - Cipher to use for symmetric encryption. Defaults to `aes-256-cbc`. Other ciphers support by OpenSSL may be used.

* `:base64` `true`/`false` - Use Base64 encoding to convert encrypted data to text. Use when binary save data storage is not available.  Defaults to `false`.

* `:padding` - Method used to pad data encrypted with the public key. Defaults to `RSA_PKCS1_PADDING`. The default should be fine unless you are dealing with legacy data.

* `:ensure_required_columns` - Make sure the required database column(s) exist.  Defaults to `true`, set to `false` if you want to encrypt/decrypt data stored outside of the database.

* `:deferred_encryption` - Defer the encryption to happen before saving the object, instead of on the assignment of the encrypted attribute. Solves issues when using [dynamic keys](http://stuff-things.net/2012/04/18/dynamic-keys-for-strongbox/). Defaults to `false`.

For example, encrypting a small attribute, providing only the public
key for extra security, and Base64 encoding the encrypted data:

```ruby
class User < ActiveRecord::Base
  validates_length_of :pin_code, :is => 4
  encrypt_with_public_key :pin_code, 
    :symmetric => :never,
    :base64 => true,
    :public_key => Rails.root.join('config','public.pem')
end
```

Strongbox can encrypt muliple attributes. `encrypt_with_public_key`
accepts a list of attributes, assuming they will use the same options:

```ruby
class User < ActiveRecord::Base
  encrypt_with_public_key :secret, :double_secret,
    :key_pair => Rails.root.join('config','keypair.pem')
end
```

If you need different options, call `encrypt_with_public_key` for each
attribute:

```ruby
class User < ActiveRecord::Base
  encrypt_with_public_key :secret,
    :key_pair => Rails.root.join('config','keypair.pem')
  encrypt_with_public_key :double_secret,
    :key_pair => Rails.root.join('config','another_key.pem')
end
```

## Key Formats

`:public_key`, `:private_key`, and `:key_pair` can be in one of the
following formats:

* A string containing path to a file. This is the default interpretation of a string.
* A string contanting a key in PEM format, needs to match this the regex `/^-+BEGIN .* KEY-+$/`
* A symbol naming a method to call. Can return any of the other valid key formats.
* A instance of `OpenSSL::PKey::RSA`. Must be unlocked to be used as the private key.

## Key Generation

### In the shell

Generate a key pair:

```shell
openssl genrsa -des3 -out config/private.pem 2048
Generating RSA private key, 2048 bit long modulus
......+++
.+++
e is 65537 (0x10001)
Enter pass phrase for config/private.pem:
Verifying - Enter pass phrase for config/private.pem:
```

and extract the the public key:

```shell
openssl rsa -in config/private.pem -out config/public.pem -outform PEM -pubout
Enter pass phrase for config/private.pem:
writing RSA key
```

If you are going to leave the private key installed it's easiest to
create a single key pair file:

```shell
cat config/private.pem  config/public.pem >> config/keypair.pem
```

Or, for added security, store the private key file else where, leaving
only the public key.

### In code

```ruby
require 'openssl'
rsa_key = OpenSSL::PKey::RSA.new(2048)
cipher =  OpenSSL::Cipher.new('des3')
private_key = rsa_key.to_pem(cipher,'password')
public_key = rsa_key.public_key.to_pem
key_pair = private_key + public_key
```

`private_key`, `public_key`, and `key_pair` are strings, store as you see fit.

## Table Creation

In it's default configuration Strongbox requires three columns, one
the encrypted data, one for the encrypted symmetric key, and one for
the encrypted symmetric IV. If symmetric encryption is disabled then
only the columns for the data being encrypted is needed.

If your underlying database allows, use the **binary** column type. If
you must store your data in text format be sure to enable Base64
encoding and to use the *text* column type. If you use a *string*
column and encrypt anything greater than 186 bytes (245 bytes if you
don't enable Base64 encoding) **your data will be lost**.

## Nil and Blank Attributes

By default, attributes set to nil will remain encrypted to protect all
information about the attribute. However, attributes may be set back
to true nil explicitly:

```ruby
# Outside the model
@object[:secret] = nil # or ''
# Inside the model
self[:secret] = '' # or nil
```

A setting to allow nil and blank attributes by default will be forth
coming.

## Security Caveats

If you don't encrypt your data, then an attacker only needs to steal
that data to get your secrets.

If encrypt your data using symmetric encrypts and a stored key, then
the attacker needs the data and the key stored on the server.

If you use public key encryption, the attacker needs the data, the
private key, and the password. This means the attacker has to sniff
the password somehow, so that's what you need to protect against.

## Authors

Spike Ilacqua

## Thanks

Strongbox's implementation drew inspiration from Thoughtbot's
[Paperclip gem](https://github.com/thoughtbot/paperclip).

Thanks to everyone who's contributed!
