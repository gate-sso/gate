# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
user = User.create(email: "dev@a.c", encrypted_password: "", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, created_at: Time.now, updated_at: Time.now, provider: nil,  name: "Dev User", auth_key: "42b57sy4alrbnmfx", provisioning_uri: "otpauth://totp/dev@a.c?secret=42b57sy4alrbnmfx.", active: true, admin: true)

(1..6).each do |uid|
  user = User.create(email: "dev#{uid}@a.c", encrypted_password: "", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, created_at: Time.now, updated_at: Time.now, provider: nil, name: "Dev User #{uid}", auth_key: "42b57sy4alrbnmfx", provisioning_uri: "otpauth://totp/dev@a.c?secret=42b57sy4alrbnmfx.", active: true, admin: false)
end

User.all.each do |user|
  host = Host.new
  host.user = user
  host.host_pattern = "s*"
  host.save!
end

group = Group.create(name: "people")

User.all.each do |user|
  user.groups << group
  user.save!
end

User.all.each do |user|
  group = Group.create(name: user.get_user_unix_name)
      user.groups << group
      user.save!
end
group = Group.create(name: "devops")
access_token = AccessToken.create(token: "a")
