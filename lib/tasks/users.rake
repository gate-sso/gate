namespace :users do
  desc 'fill user_login_id with email domain prefix'
  task migrate_user_login_id: :environment do
    User.all.each do |user|
      user.user_login_id = user.email.split('@').first
      user.save!
      puts "Migrating #{user.email}"
    end
  end

  desc 'imports users and prints their keys'
  task import_csv: :environment do
    require 'csv'
    CSV.foreach('users.csv') do |row|
      # Name, UserName
      key = User.add_temp_user(row[0], row[1])
      puts "#{key}, #{row[0]}, #{row[1]}, #{row[2]}"
    end
  end

  desc 'purge users whom have been deactivated for more than certain time'
  task :purge_inactive, [:ignore_time] => :environment do |_t, args|
    users = User.
      joins(:group_associations).
      where(active: false).
      where('group_associations.id IS NOT NULL')

    if args[:ignore_time] != 'true'
      users = users.where('deactivated_at <= :time_ago', time_ago: Time.now - 15.days)
    end

    users.each do |user|
      puts "Purging #{user.name} - #{user.email}" if !Rails.env.test?
      user.purge!
    end
  end

  desc 'revoke expired group membership'
  task revoke_expired_membership: :environment do
    GroupAssociation.revoke_expired
  end

  task add_level1: :environment do
    require 'csv'
    group = Group.where(name: 'gopay_kyc_lvl_1').first
    CSV.foreach('users.csv') do |row|
      # Name, UserName
      user_name = row[1].strip!
      user = User.get_user user_name
      puts user.get_user_unix_name + ' ' + group.name
      user.groups << group
      user.save!
    end

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
    group = Group.where(name: 'gopay_kyc_lvl_2').first
    CSV.foreach('users.csv') do |row|
      # Name, UserName
      user_name = row[1].strip!
      user = User.get_user user_name
      puts user.get_user_unix_name + ' ' + group.name
      user.groups << group
      user.save!
    end

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
