namespace :users do

  desc "migrate vpn user from old group to new groups"
  task migrate_vpns: :environment do

    vpns = Vpn.all

    vpns.each do |vpn|
      admin_groups = vpn.groups
      #create a new group for VPN
      group = Group.create(name: "#{vpn.name}_access_group", description: "VPN Access group")
      #Assign VPN to group
      #get all vpn administrators
      admins = []
      admin_groups.each do |admin_group|
        admin_group.group_admins.each do |group_admin|
          admins << group_admin.user
        end
      end

      #add all vpn administrators to new group as admin
      admins.each do |user|
        group.add_admin user
      end
      #get all vpn users
      #add all vpn users to new group
      vpn.users.each do |user|
        user.groups << group
      end
      group.save!

      @vpn.groups << group
    end
  end
end

