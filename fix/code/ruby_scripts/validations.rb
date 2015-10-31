# Numeric inputs are positive and provided in decimal without any
# leading 0's (should match /(0|[1-9][0-9]*)/). Thus "42" is a valid
# input number but the octal "052" or hexadecimal "0x2a" are not.
# Any reference to "number" below refers to this input specification.

def is_valid_balance?(balance, silent=0)
    # Balances and currency amounts are specified as a number
    # indicating a whole amount and a fractional input separated
    # by a period. The fractional input is in decimal and is always
    # two digits and thus can include a leading 0 (should match /[0-9]{2}/).
    # The interpretation of the fractional amount v is that of having
    # value equal to v/100 of a whole amount (akin to cents and dollars in
    # US currency). Balances are bounded from 0.00 to 4294967295.99.
    if balance =~ /^(\d{1,10}).(\d{2})$/
      left_part = balance.split(".")[0]
      if left_part == "0" || left_part[0] != "0"
        balance = balance.to_f
        if balance >= 0.0 && balance <= 4294967295.99
            return true
        end
      end
    end

    debug "Invalid balance: #{balance}" unless silent
    false
end

def is_valid_amount?(amount)
    # Uses the same validation as is_valid_balance?
    result = is_valid_balance?(amount, 1)
    debug "Invalid amount: #{amount}" unless result 

    return result
end

def is_valid_account?(account)
  if account.length >= 1 \
    && account.length <= 250 \
    && account =~ /\A[a-z0-9_\-\.]+\Z/
      return true
  end

  debug "Invalid account: #{account}"
  false
end

def is_valid_ip?(ip)
  unless ip =~ /\A([0-9]{1,3}).([0-9]{1,3}).([0-9]{1,3}).([0-9]{1,3})\z/
    debug "Invalid ip #{ip}"
    return false
  end

  if ["0.0.0.0","10.0.0.0","172.16.0.0","192.168.0.0"].include?(ip)
    debug "Invalid ip -- network address"
    return false
  end

  if ["255.255.255.255","10.255.255.255","172.31.255.255","192.168.255.255"].include?(ip)
    debug "Invalid ip -- broadcast address"
    return false
  end

  ip.split(".").each do |octect|
    if octect.start_with?("0") && octect.length > 1
      debug "Invalid ip -- cant start with 0"
      return false
    end

    if octect.to_i > 255
      debug "Invalid ip -- #{octect} cant be greater than 255"
      return false
    end
  end

  true
end

def is_valid_port?(port)
  # Regex check
  unless port =~ /\A([1-9]{1})([0-9]{3,4})\z/
    debug "Invalid port"
    return false
  end

  # p<1024 and p>65535 are invalid
  p = port.to_i
  if p >= 1024 && p <= 65535
    return true
  end
  
  debug "Invalid port: #{p}"
  false
end

def is_valid_auth_file?(auth_file, silent=0)
  if ![".",".."].include?(auth_file) \
    && auth_file.length >= 1 \
    && auth_file.length <= 255 \
    && auth_file =~ /\A[a-z0-9_\-\.]+\Z/
      return true
  end

  debug "Invalid auth file: #{auth_file}" unless silent
  false
end

def is_valid_card_file?(card_file)
  result = is_valid_auth_file?(card_file, 1)

  debug "Invalid card_file: #{card_file}" unless result 
  return result
end

def is_valid_message_id?(message_id)
  if message_id.length >= 1 \
    && message_id.length <= 255 \
    && message_id =~ /\A[a-z0-9_\-\.]+\Z/
      return true
  end

  debug "Invalid message_id: #{message_id}"
  false
end

def are_valid_args?(args, auth_file)
  # ATM time
  if !args[:message_id] || !is_valid_message_id?(args[:message_id])
    debug "are_valid_args? invalid message ID"
    return false
  end

  # Account Name
  if !args[:account] || !is_valid_account?(args[:account])
    debug "are_valid_args? invalid account"
    return false
  end

  # Card File
  if !args[:card_file] || !is_valid_card_file?(args[:card_file])
    debug "are_valid_args? invalid card file"
    return false
  end

  # Auth File
  if !args[:auth_file] || !is_valid_auth_file?(args[:auth_file]) || args[:auth_file]!=auth_file
    debug "are_valid_args? invalid auth file"
    return false
  end

  # Operations
  if !args[:operation] || !["-n","-d","-w","-g"].include?(args[:operation])
    debug "are_valid_args? invalid operation"
    return false
  end

  # -n
  if args[:operation] == "-n" && !is_valid_balance?(args[:operation_value])
    debug "are_valid_args? invalid balance for -n operation"
    return false
  end

  # -d, -w
  if ["-d","-w"].include?(args[:operation]) && !is_valid_amount?(args[:operation_value])
    debug "are_valid_args? invalid amount for operations -d or -w"
    return false
  end

  return true
end

