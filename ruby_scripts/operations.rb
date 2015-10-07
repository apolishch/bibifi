def operation_n(args)
    all = File.open(args[:auth_file], "r").read
    found_account = false
    all.split("\n").each do |entry|
        values = entry.split(";")
        if values[0] == args[:account]
            found_account = true
        end
    end

    if found_account
        return { :error => "Account already exists"}
    end

    File.open(args[:auth_file], "a") do |f|
        f << "#{args[:account]};n;;#{Time.now}\n"
        f << "#{args[:account]};d;#{args[:operation_value]};#{Time.now}\n"
    end

    {
        :account => args[:account].to_s,
        :initial_balance => args[:operation_value].to_f.round(2)
    }
end

def operation_d(args)
    all = File.open(args[:auth_file], "r").read
    found_account = false
    all.split("\n").each do |entry|
        values = entry.split(";")
        if values[0] == args[:account]
            found_account = true
        end
    end

    unless found_account
        return { :error => "Account not found"}
    end

    File.open(args[:auth_file], "a") do |f|
        f << "#{args[:account]};d;#{args[:operation_value]};#{Time.now}\n"
    end

    {
        :account => args[:account].to_s,
        :deposit => args[:operation_value].to_f.round(2)
    }
end

def operation_w(args)
    all = File.open(args[:auth_file], "r").read
    balance = 0.0
    found_account = false
    all.split("\n").each do |entry|
        values = entry.split(";")
        if values[0] == args[:account]
            found_account = true

            if values[1] == "d"
                balance += values[2].to_f
            end

            if values[1] == "w"
                balance -= values[2].to_f
            end
        end
    end

    unless found_account
        return { :error => "Account not found"}
    end

    if balance.round(2) - args[:operation_value].to_f < 0
        return { :error => "Invalid amount"}
    end

    File.open(args[:auth_file], "a") do |f|
        f << "#{args[:account]};w;#{args[:operation_value]};#{Time.now}\n"
    end

    {
        :account  => args[:account].to_s,
        :withdraw => args[:operation_value].to_f.round(2)
    }
end

def operation_g(args)
    all = File.open(args[:auth_file], "r").read
    balance = 0.0
    found_account = false
    all.split("\n").each do |entry|
        values = entry.split(";")
        if values[0] == args[:account]
            found_account = true
            if values[1] == "d"
                balance += values[2].to_f
            end

            if values[1] == "w"
                balance -= values[2].to_f
            end
        end
    end

    unless found_account
        return { :error => "Account not found"}
    end

    File.open(args[:auth_file], "a") do |f|
        f << "#{args[:account]};g;;#{Time.now}\n"
    end

    {
        :account => args[:account].to_s,
        :balance => balance.to_f.round(2)
    }
end

