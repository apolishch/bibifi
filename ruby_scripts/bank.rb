# bank is a server than simulates a bank, whose job is to keep track
# of the balance of its customers. It will receive communications
# from atm clients on the specified TCP port. Example interactions
# with bank and the atm are given at the bottom of the main page.

options = {}

optparse = OptionParser.new do |opts|  
  opts.banner = "Usage: bank [-p <port>] [-s <auth-file>]"
  opts.separator  ""
  opts.separator  "Options"

  text = "Help"
  opts.on("-h","--help",text) do |input|
    exit(EXIT_CODE)
  end

  text = "The port that bank should listen on. The default is 3000."
  opts.on("-p <port>","",text) do |input|
    exit(EXIT_CODE) unless is_valid_port?(input)
    options[:port] = input
  end

  text = "The name of the auth file. If not supplied, defaults to \"bank.auth\""
  opts.on("-s <auth-file>","",text) do |input|
    exit(EXIT_CODE) unless is_valid_auth_file?(input)
    options[:auth_file] = input
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
port      = (options[:port]      || "3000").to_i
auth_file = options[:auth_file]  || "bank.auth"

# ...  if the specified file already exists,
# bank should exit with return code 255.
if File.exist?(auth_file)
  debug "File already exists: #{auth_file}"
  exit(EXIT_CODE)
end

# Once the auth file is written completely, 
# bank prints "created" (followed by a newline)
# to stdout. bank will not change the auth file
# once "created" has been printed.
$secret_key = OpenSSL::Cipher::AES256.new(:CBC).random_key
debug Base64.encode64($secret_key)

begin
  File.open(auth_file,  "w") do |f|
    f << Base64.encode64($secret_key) + "\n"
  end
  STDOUT.puts "created"
  STDOUT.flush
rescue Errno::EACCES
  debug "No permission to write file: #{auth_file}"
  exit(EXIT_CODE)
end

#
## Bank TCP Server
#
# If an error is detected in the protocol's communication,
# atm should exit with return code 63, while bank should
# print "protocol_error" to stdout (followed by a newline)
# and roll back (i.e., undo any changes made by) the current
# transaction.
server = TCPServer.new("127.0.0.1", port)
message_counter = 0
begin
  loop do
    begin
      begin
         client, client_sockaddr = server.accept_nonblock   # Wait for a client to connect
      rescue Errno::EAGAIN, Errno::ECONNABORTED, Errno::EINTR, Errno::EWOULDBLOCK
        IO.select([server])
        retry
      end
      
      Timeout::timeout(10) do
        client_input = client.gets  # Wait for a client input
        debug "received #{client_input}"

        # Decrypt
        begin
          client_input = decrypt(client_input)
        rescue => e
          debug "failed to decrypt: #{e.inspect}"
          client.puts encrypt({ :error => "failed to decrypt" }.to_json)
          client.close
          next
        end

        # Parse
        begin
          client_input = JSON.parse(client_input)
        rescue JSON::ParserError
          debug "failed to parse json"
          client.puts encrypt({ :error => "failed to parse" }.to_json)
          client.close
          next
        end

        # Verify Input
        if !client_input["input"] || !client_input["input"].is_a?(Array) || !client_input['input'][-2] == 'message_id'
            debug "invalid input"
            client.puts encrypt({ :error => "invalid input" }.to_json)
            client.close
            next
        else
          message_id = client_input['input'].last
        end

        # Extract arguments from client input
        args = {}
        client_input["input"].each_with_index do |v, index|
          key = nil

          case v
            when "message_id"
              key = "message_id"
            when "-a"
              key = "account"
            when "-c"
              key = "card_file"
            when "-s"
              key = "auth_file"
            when "-n", "-d", "-w", "-g"
              args[:operation] = v
              key = "operation_value" unless v=="-g"  # -g doesn't have a value
          end

          # Index check -- just to make sure that there is
          # a next value followed by the key. E.g.,
          # When the key is "-n" we supposed that there is
          # the next value, which will be amount for instance.
          # So we check if the index exists (index+1) as some
          # keys doesn't need indexes, such as "-g".
          if key && (index + 1 <= client_input["input"].count)
            args[:"#{key}"] = client_input["input"][index + 1]
          end
        end

        # Verify Input
        if !are_valid_args?(args, auth_file)
          debug "invalid args"
          client.puts encrypt({ :error => "invalid arguments" }.to_json)
          client.close
          next
        end

        # Execute Operations
        output = {}
        output[:body] = case args[:operation]
          when "-n"
            operation_n(args)
          when "-d"
            operation_d(args)
          when "-w"
            operation_w(args)
          when "-g"
            operation_g(args)
          else
            debug "invalid operation"
            debug "args: #{args}"
            client.puts encrypt({ :error => "invalid operation" }.to_json)
            client.close
            next
        end

        unless output[:body][:error]
          STDOUT.puts output[:body].to_json           # prints on console
          STDOUT.flush
        end
        
        output[:message_id] = message_id
        client.puts encrypt(output.to_json)    # prints on socket
        client.close
        message_id = nil
        next
      end

    rescue => e
      if (e.class == Timeout::Error)
         puts "protocol_error"
         STDOUT.flush
      else
        raise e
      end
    end
  end
rescue => e
  debug "generic error #{e.class}: #{e.message} \nBacktrace #{e.backtrace}"
  exit(EXIT_CODE)
end
