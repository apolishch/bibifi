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
    if balance(args[:auth_file], args[:account]).nil?
        return { :error => "Account not found"}
    end

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


def add_entry(auth_file, user, operation, value, atm_time)
    current_time = Time.now
    to_sign = "#{user}#{operation}#{value}#{atm_time}#{current_time}"
    signature = sign(to_sign)

    # Security Check
    # Verify duplicate (replay attack attempts)
    replay_attack_attempt = false
    entries = File.open(auth_file, "r").read
    entries.split("\n").each do |e|
        values = e.split(";")
        next unless validate_entry(values)

        if values[0..3] == [user, operation, value, atm_time]
            replay_attack_attempt = true
            break
        end
    end

    if replay_attack_attempt
        return false
    end

    # Add entry
    File.open(auth_file, "a") do |f|
        f << [user, operation, value, atm_time, current_time, signature].join(";") + "\n"
    end

    return true
end

def balance(auth_file, user)
    # return nil if user does not exist
    all = File.open(auth_file, "r").read
    total = 0.0
    account_exists = false
    all.split("\n").each do |e|
        values = e.split(";")
        next unless validate_entry(values)

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

def validate_entry(values)
    return false if values.count != 6
    to_sign = values[0..4].join("")
    
    return sign(to_sign) == values.last
end