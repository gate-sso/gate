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
end
