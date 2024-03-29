#
# atm is a client program that simulates an ATM by providing
# a mechanism for customers to interact with their bank accounts
# stored on the bank server. atm allows customers to 
# - create new accounts,
# - deposit money,
# - withdraw funds, and
# - check their balances.
# 
# In all cases, these functions are achieved via communiations with
# the bank. atm cannot store any state or write to any files except
# the card-file. The card-file can be viewed as the "pin code" for
# one's account; there is one card file per account.
# 
# Card files are created when atm is invoked with -n to create a new
# account; otherwise, card files are only read, and not modified.
#
# Any invocation of the atm which does not follow the four enumerated
# possibilities above should exit with return code 255 (printing nothing).
# Noncompliance includes a missing account or mode of operation and
# duplicated parameters. Note that parameters may be specified in any order.

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: atm -a <account> [-s <auth-file>] [-i <ip-address>] [-p <port>] [-c <card-file>]"
  opts.separator  ""
  opts.separator  "Options"

  text = "Help"
  opts.on("-h","--help",text) do |input|
    exit(EXIT_CODE)
  end

  # Account
  text = "The customer's account name."
  opts.on("-a <account>","",text) do |input|
    exit(EXIT_CODE) unless is_valid_account?(input)
    options[:account] = input
  end

  # Auth File
  text = "The name of the auth file. If not supplied, defaults to \"bank.auth\""
  opts.on("-s <auth-file>","",text) do |input|
    exit(EXIT_CODE) unless is_valid_auth_file?(input)
    options[:auth_file] = input
  end

  # IP Address
  text = "The IP address that bank is running on. The default value is \"127.0.0.1\"."
  opts.on("-i <ip-address>","",text) do |input|
    exit(EXIT_CODE) unless is_valid_ip?(input)
    options[:ip] = input
  end

  # Port
  text = "The port that bank should listen on. The default is 3000."
  opts.on("-p <port>","",text) do |input|
    exit(EXIT_CODE) unless is_valid_port?(input)
    options[:port] = input
  end

  # Card File
  text = "The customer's atm card file. The default value is the account " \
  "name prepended to \".card\" (\"<account>.card\"). For example, if the " \
  "account name was 55555, the default card file is \"55555.card\"."
  opts.on("-c <card-file>","",text) do |input|
    exit(EXIT_CODE) unless is_valid_card_file?(input)
    options[:card_file] = input
  end

  ##
  # Mode of Operations

  # -n: Create a new account with the given balance.
  text = "Create a new account with the given balance. The account must be" \
  "unique (ie, the account must not already exist). The balance must be " \
  "greater than or equal to 10.00. The given card file must not already " \
  "exist. If any of these conditions do not hold, atm exits with a return" \
  " code of 255. On success, both atm and bank print the account and initial" \
  " balance to standard output, encoded as JSON. The account name is a JSON" \
  " string with key \"account\", and the initial balance is a JSON number with" \
  " key \"initial_balance\" (Example: {\"account\":\"55555\",\"initial_balance\":10.00})." \
  " In addition, atm creates the card file for the new account " \
  "(think of this as like an auto-generated pin)."
  opts.on("-n <balance>","",text) do |input|
    exit(EXIT_CODE) if options[:operation]
    exit(EXIT_CODE) unless is_valid_balance?(input)
    unless input.to_f >= 10.00
      debug "Input lesser than 10"
      exit(EXIT_CODE) 
    end

    options[:operation] = "n"
    options[:operation_value] = input
  end

  # -d: Deposit the amount of money specified
  text = 'Deposit the amount of money specified. The amount must be greater' \
  ' than 0.00. The specified account must exist, and the card file must be' \
  ' associated with the given account (i.e., it must be the same file produced' \
  ' by atm when the account was created). If any of these conditions do not hold,' \
  ' atm exits with a return code of 255. On success, both atm and bank print the' \
  ' account and deposit amount to standard output, encoded as JSON. The account ' \
  'name is a JSON string with key "account", and the deposit amount is a JSON ' \
  'number with key "deposit" (Example: {"account":"55555","deposit":20.00}).'
  opts.on("-d <amount>","",text) do |input|
    exit(EXIT_CODE) if options[:operation]
    exit(EXIT_CODE) unless is_valid_amount?(input)
    unless input.to_f > 0.00
      debug "Input lesser than 0"
      exit(EXIT_CODE) 
    end
    options[:operation] = "d"
    options[:operation_value] = input
  end

  # -w: Withdraw the amount of money specified
  text = 'Withdraw the amount of money specified. The amount must be greater ' \
  'than 0.00, and the remaining balance must be nonnegative. The card file' \
  ' must be associated with the specified account (i.e., it must be the same' \
  ' file produced by atm when the account was created). The ATM exits with a ' \
  'return code of 255 if any of these conditions are not true. On success, ' \
  'both atm and bank print the account and withdraw amount to standard output,' \
  ' encoded as JSON. The account name is a JSON string with key "account", and' \
  ' the withdraw amount is a JSON number with key "withdraw" (Example:'\
  ' {"account":"55555","withdraw":15.00}).'
  opts.on("-w <amount>","",text) do |input|
    exit(EXIT_CODE) if options[:operation]
    exit(EXIT_CODE) unless is_valid_amount?(input)
    unless input.to_f > 0.00
      debug "Input lesser than 0"
      exit(EXIT_CODE) 
    end
    options[:operation] = "w"
    options[:operation_value] = input
  end

  # -g: Get the current balance of the account
  text = 'Get the current balance of the account. The specified account must '\
  'exist, and the card file must be associated with the account. Otherwise, '\
  'atm exits with a return code of 255. On success, both atm and bank print '\
  'the account and balance to stdout, encoded as JSON. The account name is '\
  'a JSON string with key "account", and the balance is a JSON number with '\
  'key "balance" (Example: {"account":"55555","balance":43.63}).'
  opts.on("-g","",text) do |input|
    exit(EXIT_CODE) if options[:operation]
    options[:operation] = "g"
  end

end

begin
  optparse.parse!
rescue
  debug "invalid arguments #{options.inspect}"
  exit(EXIT_CODE)
end

# Check required conditions
unless ARGV.empty?
  debug "Extra parameters"
  exit(EXIT_CODE)
end

# Debug: print received options
debug options.inspect

# Default Parameters Values
account         = options[:account]
operation       = options[:operation]
operation_value = options[:operation_value]
ip              = options[:ip]        || "127.0.0.1"
port            = (options[:port]     || "3000").to_i
auth_file       = options[:auth_file] || "bank.auth"
card_file       = options[:card_file] || "#{options[:account]}.card"


# Mandatory parameters verification
unless account && operation
  debug "Not specified argument, one of account: #{account}, operation: #{operation}"
  exit(EXIT_CODE)
end

# If the specified file cannot be opened,
# the atm exits with a return code of 255.
unless File.exist?(auth_file)
  debug "File does not exist: #{auth_file}"
  exit(EXIT_CODE)
end

begin
  $secret_key = Base64.decode64(File.open(auth_file, "r").read.split("\n").first)
  debug Base64.encode64($secret_key)
rescue Errno::EACCES
  debug "No permission to open file: #{auth_file}"
  exit(EXIT_CODE)
end

#
# ================= OPERATION SPECIFIC
#

if operation == "n"
  # Create Card File if operation is "-n"
  if File.exist?(card_file)
    debug "Card File exists: #{card_file}"
    exit(EXIT_CODE)
  end

  begin
      File.open(card_file, "w") do |f|
        f << generate_hash(account)
      end
  rescue Errno::ENOENT
    debug "Could not create: #{card_file} | ENOENT"
    exit(EXIT_CODE)
  rescue Errno::EACCES
    debug "Could not create: #{card_file} | EACCES"
    exit(EXIT_CODE)
  end
end

if ["d","w","g"].include?(operation)
  # Check if account/card exists
  unless File.exist?(card_file)
    debug "File not found: #{card_file}"
    exit(EXIT_CODE)
  end

  # Check if has permission to open file
  begin
    f = File.open(card_file,  "r")
  rescue Errno::EACCES
    debug "No permission to open file: #{card_file}"
    exit(EXIT_CODE)
  end

  # Is its size >= 1 MB?
  if (File.size(card_file).to_f / 1024000) >= 1
    debug "Card file too big: #{File.size(card_file).to_f}"
    exit(EXIT_CODE)
  end

  # Read Contents
  card_file_contents = File.open(card_file, "rb").read

  # Check if they match (account/card_file), a.k.a Authentication
  unless card_file_contents == generate_hash(account)
    debug "Invalid account or card file"
    exit(EXIT_CODE)
  end
end

## TCP Communication w/ BANK
# 

begin
  Timeout::timeout(10) do
    Socket.tcp(ip, port) {|sock|
      # A timeout occurs if the other program does not respond
      # within 10 seconds. If the atm observes the timeout, it
      # should exit with return code 63

      input = [
            "-p",
            port.to_s,
            "-i",
            ip,
            "-a",
            account,
            "-c",
            card_file,
            "-s",
            auth_file,
            "-#{operation}"
        ]
      # As -g does not have a value
      # We only add the operation_value if not empty
      input << operation_value if operation_value

      # Time to prevent replay attacks
      message_id = generate_message_id()
      input << "message_id"
      input << message_id

      message = {
        input: input,
        base64: false
      }.to_json

      sock.print encrypt(message)
      sock.close_write
      raw_result = sock.read

      # Decrypt
      begin
        raw_result = decrypt(raw_result)
      rescue OpenSSL::Cipher::CipherError => e
        debug "failed to decrypt: #{e.inspect}"
        exit(PROTOCOL_EXIT_CODE)
        return
      end

      # JSON Parse
      begin
        result = JSON.parse(raw_result)
      rescue JSON::ParserError
        debug "json parser error"
        exit(PROTOCOL_EXIT_CODE)
        return
      end

      # Exit when bank announce an error / violation
      if result['body']["error"]
        debug "Exiting as bank said to #{result}"
        exit(EXIT_CODE)
        return
      end

      if (result['message_id'] != message_id)
        debug "Exiting as message_ids do not match"
        exit(PROTOCOL_EXIT_CODE)
        return
      end

      STDOUT.puts JSON.generate(result['body'])
      STDOUT.flush
    }
  end
rescue => e
    # If an error is detected in the protocol's communication,
    # atm should exit with return code 63, while bank should
    # print "protocol_error" to stdout (followed by a newline)
    # and roll back (i.e., undo any changes made by) the current
    # transaction.
    if (operation === "n" && e.class == Timeout::Error)
      File.delete(card_file)
    end

    debug "generic socket rescue: #{e.class}: #{e.message} \nBacktrace #{e.backtrace}"
    exit(PROTOCOL_EXIT_CODE)
end
