def operation_n(args)
    unless balance(args[:auth_file], args[:account]).nil?
        return { :error => "Account already exists"}
    end

    unless add_entry(args[:auth_file], args[:account], "n", args[:operation_value], args[:atm_time])
        return { :error => "Replay attack detected"}
    end

    {
        :account => args[:account].to_s,
        :initial_balance => args[:operation_value].to_f.round(2)
    }
end

def operation_d(args)
    b = balance(args[:auth_file], args[:account])
    return { :error => "Account not found"} if b.nil?

    unless add_entry(args[:auth_file], args[:account], "d", args[:operation_value], args[:atm_time])
        return { :error => "Replay attack detected"}
    end

    {
        :account => args[:account].to_s,
        :deposit => args[:operation_value].to_f.round(2)
    }
end

def operation_w(args)
    b = balance(args[:auth_file], args[:account])
    return { :error => "Account not found"} if b.nil?

    if b - args[:operation_value].to_f < 0
        return { :error => "Invalid amount"}
    end

    unless add_entry(args[:auth_file], args[:account], "w", args[:operation_value], args[:atm_time])
        return { :error => "Replay attack detected"}
    end

    {
        :account  => args[:account].to_s,
        :withdraw => args[:operation_value].to_f.round(2)
    }
end

def operation_g(args)
    b = balance(args[:auth_file], args[:account])
    return { :error => "Account not found"} if b.nil?

    unless add_entry(args[:auth_file], args[:account], "g", nil, args[:atm_time])
        return { :error => "Replay attack detected"}
    end

    {
        :account => args[:account].to_s,
        :balance => b
    }
end

$entries = []

def add_entry(auth_file, user, operation, value, atm_time)
    # Security Check
    # Verify duplicate (replay attack attempts)
    return false if $entries.include?([user, operation, value, atm_time])

    # Add entry
    $entries << [user, operation, value, atm_time]
    return true
end

def balance(auth_file, user)
    # return nil if user does not exist
    all = File.open(auth_file, "r").read
    total = 0.0
    account_exists = false
    $entries.each do |values|
        if values[0] == user
            account_exists = true
            if ["n","d"].include?(values[1])
                total += values[2].to_f
            end

            if ["w"].include?(values[1])
                total -= values[2].to_f
            end
        end
    end

    return nil unless account_exists
    return total.round(2)
end

