namespace :setup do
  desc "Setup open vpn config"

  task :openvpn => [:key_dir, :certificate_authority] do
  end

  task :key_dir do
    key_dir = Net::Openvpn::Generators::Keys::Directory.new
    key_dir.generate
    puts "#{key_dir} successfully generated" if key_dir.exist?
  end

  task :certificate_authority do
    ca = Net::Openvpn::Generators::Keys::Authority.new
    ca.generate
    ca.exist?
    puts "#{ca} successfully generated" if ca.exist?
  end

  task :server do
    keys = Net::Openvpn::Generators::Keys::Server.new("swzvpn04")
    keys.generate
    keys.exist?
    keys.valid?
  end

  # example rake setup:client['ajey']
  task :client , [:name] => :environment do |task, args|
    puts "generating key for #{args.name}"
    keys = Net::Openvpn::Generators::Keys::Client.new(args.name)
    keys.generate
    keys.exist?
    keys.valid?
    puts "key for #{args.name} successfully generated" if keys.valid?
  end
end
