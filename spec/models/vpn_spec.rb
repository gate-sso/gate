require 'rails_helper'

RSpec.describe Vpn, type: :model do
  context "vpn administration" do

    it "should test user and vpn management" do

      vpn = Vpn.create(name: :"X")
      group = create(:group)
      vpn.groups << group
      vpn.save!

      user = create(:user)

      group.users << user
      group.save!

      expect(Vpn.administrator? user).to eq false

      group.add_admin user

      expect(Vpn.administrator? user).to eq true
      expect(Vpn.managed_vpns(user).count).to eq 1
      vpn = Vpn.create(name: :"Y")
      vpn.groups << group
      vpn.save!
      expect(Vpn.managed_vpns(user).count).to eq 2
      vpn = Vpn.create(name: :"Z")
      expect(Vpn.managed_vpns(user).count).to eq 2
      vpn = Vpn.create(name: :"Z1")
      group = create(:group)
      vpn.groups << group
      vpn.save!
      expect(Vpn.managed_vpns(user).count).to eq 2
      group.users << user
      group.save!
      group.add_admin user
      expect(Vpn.managed_vpns(user).count).to eq 3
    end

    it "should list all vpns for given user" do


      vpn = Vpn.create(name: :"X")
      group = create(:group)
      vpn.groups << group
      vpn.save!

      user = create(:user)

      if !group.member? user
        group.users << user 
        group.save!
      end

      expect(Vpn.user_vpns(user).count).to eq 1
      vpn = Vpn.create(name: :"Y")
      vpn.groups << group
      vpn.save!
      expect(Vpn.user_vpns(user).count).to eq 2
      vpn = Vpn.create(name: :"Z")
      expect(Vpn.user_vpns(user).count).to eq 2
      vpn = Vpn.create(name: :"Z1")
      group = create(:group)
      group.users << user
      vpn.groups << group
      vpn.save!
      expect(Vpn.user_vpns(user).count).to eq 3


    end
  end
end

