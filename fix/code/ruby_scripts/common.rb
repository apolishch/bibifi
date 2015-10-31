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

def generate_hash(value)
    OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('sha256'),
        $secret_key,
        value
    ).strip()
end

# Generator of 128-bit pseudo random numbers
# Returns number in hex format in a string
def generate_message_id()
    OpenSSL::Random.random_bytes(16).unpack("H*")[0]
end

def debug(msg)
  return false unless DEBUG
  flag = "a"
  flag = "w" unless File.exist?("debug.txt")

  File.open("debug.txt", flag) do |f|
    f << msg
  end
end

def encrypt(plain_text)
    cipher = OpenSSL::Cipher.new('aes-128-gcm')
    cipher.encrypt
    cipher.key = $secret_key
    iv = cipher.random_iv
    cipher.iv = iv
    ciphertext = cipher.update(addPadding(plain_text)) + cipher.final

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
    removePadding(cipher.update(ciphertext)) + cipher.final
end

def addPadding(s)
    p = "||"
    random_string = OpenSSL::Random.random_bytes(125).unpack("H*")[0]
    (1..(250 - p.size - s.size)).each do |i|
        p += random_string[i]
    end

    return s + p
end

def removePadding(s)
    s.split("||").first
end

# All other errors, specified throughout this document or
# unrecoverable errors not explicitly discussed, should prompt the
# program to exit with return code 255

