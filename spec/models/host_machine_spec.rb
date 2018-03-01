require 'rails_helper'

RSpec.describe HostMachine, type: :model do
  context "access" do

    it "should compute overall groups and returns members in sysadmins group" do
      host_machine = create(:host_machine)
      group = create(:group)
      user = create(:user)


      group = create(:group)
      group.host_machines << host_machine
      if !group.member? user
        group.users << user
      end
      group.save!
      group.reload

      expect(host_machine.sysadmins.count).to eq 1

      user = create(:user)
      if !group.member? user
        group.users << user
      end
      group.save!
      host_machine.reload


      expect(host_machine.sysadmins.count).to eq 2
      group = create(:group)
      group.host_machines << host_machine
      group.save!

      host_machine.reload

      expect(host_machine.sysadmins.count).to eq 2
      group.users << user
      group.save!
      host_machine.reload
      expect(host_machine.sysadmins.count).to eq 2

      user = create :user

      group.users << user
      group.save!
      host_machine.reload
      expect(host_machine.sysadmins.count).to eq 3
    end
  end

  context "sysadmin_group" do
    it "should return sysadmins, their groups and sysadmin group container sysadmins" do

      host_machine = create(:host_machine)
      group = create(:group)
      user = create(:user)


      group = create(:group)
      group.host_machines << host_machine
      if !group.member? user
        group.users << user
      end

      user = create(:user)
      if !group.member? user
        group.users << user
      end
      group.save!
      host_machine.reload
      group.reload

      expect(host_machine.sysadmins.count).to eq 2
      response = Group.get_sysadmins_and_groups host_machine.sysadmins
      sysadmins_and_groups = JSON.parse(response)

      expect(sysadmins_and_groups.count).to eq 3

    end
  end
end
