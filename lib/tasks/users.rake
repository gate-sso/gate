namespace :users do
  desc "imports users and prints their keys"
  task import_csv: :environment do
    require 'csv'
    CSV.foreach("users.csv") do |row|
      #Name, UserName
      key = User.add_temp_user(row[0], row[1])
      puts ("#{key}, #{row[0]}, #{row[1]}, #{row[2]}")
    end
  end

  task add_level1: :environment do
    require 'csv'
    group = Group.where(name: "gopay_kyc_lvl_1").first
    CSV.foreach("users.csv") do |row|
      #Name, UserName
      user_name  = row[1].strip!
      user = User.get_user user_name
      puts user.get_user_unix_name + " " + group.name
      user.groups << group
      user.save!
    end

    REDIS_CACHE.del(GROUP_NAME_RESPONSE + group.name)
    REDIS_CACHE.del(GROUP_GID_RESPONSE + group.gid.to_s)

    @response = Group.get_all_response.to_json
    REDIS_CACHE.set(GROUP_ALL_RESPONSE, @response)
    REDIS_CACHE.expire(GROUP_ALL_RESPONSE, REDIS_KEY_EXPIRY)
    @response = User.get_all_shadow_response.to_json
    REDIS_CACHE.set(SHADOW_ALL_RESPONSE, @response)
    REDIS_CACHE.expire(SHADOW_ALL_RESPONSE, REDIS_KEY_EXPIRY)
    @response = User.get_all_passwd_response.to_json
    REDIS_CACHE.set(PASSWD_ALL_RESPONSE, @response)
    REDIS_CACHE.expire(PASSWD_ALL_RESPONSE, REDIS_KEY_EXPIRY)

  end

  task add_level2: :environment do
    require 'csv'
    group = Group.where(name: "gopay_kyc_lvl_2").first
    CSV.foreach("users.csv") do |row|
      #Name, UserName
      user_name  = row[1].strip!
      user = User.get_user user_name
      puts user.get_user_unix_name + " " + group.name
      user.groups << group
      user.save!
    end


    REDIS_CACHE.del(GROUP_NAME_RESPONSE + group.name)
    REDIS_CACHE.del(GROUP_GID_RESPONSE + group.gid.to_s)

    @response = Group.get_all_response.to_json
    REDIS_CACHE.set(GROUP_ALL_RESPONSE, @response)
    REDIS_CACHE.expire(GROUP_ALL_RESPONSE, REDIS_KEY_EXPIRY)
    @response = User.get_all_shadow_response.to_json
    REDIS_CACHE.set(SHADOW_ALL_RESPONSE, @response)
    REDIS_CACHE.expire(SHADOW_ALL_RESPONSE, REDIS_KEY_EXPIRY)
    @response = User.get_all_passwd_response.to_json
    REDIS_CACHE.set(PASSWD_ALL_RESPONSE, @response)
    REDIS_CACHE.expire(PASSWD_ALL_RESPONSE, REDIS_KEY_EXPIRY)

  end

end
