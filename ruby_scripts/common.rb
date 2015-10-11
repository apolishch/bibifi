#!/usr/bin/ruby
require 'optparse'
require 'socket'
require 'timeout'
require 'json'
require 'openssl'
require 'base64'

Signal.trap('INT')  { exit 0 } # Trap ^C      == "INT"
Signal.trap('TERM') { exit 0 } # Trap `Kill ` == "TERM"

DEBUG = false
EXIT_CODE  = 255
PROTOCOL_EXIT_CODE = 63
DEVICE_KEY = OpenSSL::Cipher::AES128.new(:CBC).random_key

def generate_hash(value)
    OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('sha256'),
        $secret_key,
        value
    ).strip()
end

def debug(msg)
  puts msg if DEBUG
end

def encrypt(plain_text)
    cipher = OpenSSL::Cipher.new('aes-128-gcm')
    cipher.encrypt
    cipher.key = $secret_key
    iv = cipher.random_iv
    cipher.iv = iv
    ciphertext = cipher.update(plain_text) + cipher.final

    [ciphertext, iv, cipher.auth_tag].map{
        |x| Base64.strict_encode64(x) }.join(":")
end

def decrypt(text)
    ciphertext, iv, auth_tag = text.split(":").map{ |x| Base64.decode64(x) }
    cipher = OpenSSL::Cipher.new('aes-128-gcm')
    cipher.decrypt
    cipher.key = $secret_key
    cipher.iv = iv
    cipher.auth_tag = auth_tag
    cipher.update(ciphertext) + cipher.final 
end

def sign(text)
    OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('sha256'),
        DEVICE_KEY,
        text
    ).strip()
end

# All other errors, specified throughout this document or
# unrecoverable errors not explicitly discussed, should prompt the
# program to exit with return code 255

