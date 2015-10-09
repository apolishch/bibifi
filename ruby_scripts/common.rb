#!/usr/bin/ruby
require 'optparse'
require 'socket'
require 'timeout'
require 'json'
require 'openssl'

Signal.trap('INT')  { exit 0 } # Trap ^C      == "INT"
Signal.trap('TERM') { exit 0 } # Trap `Kill ` == "TERM"

SECRET_KEY = 'HUDFaSDh9130fsaklrm1d>>>Dsax__+d1'
EXIT_CODE  = 255
PROTOCOL_EXIT_CODE = 63

def generate_hash(value)
    OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('sha256'),
        SECRET_KEY,
        value
    ).strip()
end

def debug(msg)
  # Comment below to disable all debug messages
  #puts msg
end

# All other errors, specified throughout this document or
# unrecoverable errors not explicitly discussed, should prompt the
# program to exit with return code 255
# >>>> it's from RAILS 
# >>>> http://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html
#rescue_from 'SystemCallError' do |e|
    #debug e.class.name.to_s
    #exit(EXIT_CODE)
#end

