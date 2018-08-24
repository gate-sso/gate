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

  context 'add_host_group' do
    let(:host_machine) { HostMachine.find_or_create_by(name: 'machine')  }
    it 'should create host group given valid name' do
      host_machine.add_host_group(host_machine.name)
      groups = host_machine.groups.map(&:name)
      expect(groups.include?("#{host_machine.name}_host_group")).to eq(true)
      expect(host_machine.valid?).to eq(true)
    end

    it 'should create the group with all downcase' do
      host_machine.add_host_group(host_machine.name.upcase)
      groups = host_machine.groups.map(&:name)
      expect(groups.include?("#{host_machine.name.downcase}_host_group")).to eq(true)
    end

    it 'should not add the group if the name is invalid' do
      host_machine.add_host_group('')
      groups = host_machine.groups.map(&:name)
      expect(groups.include?("")).to eq(false)
      expect(groups.include?("_host_group")).to eq(false)
    end
  end

  context 'add_group' do
    let(:host_machine) { HostMachine.find_or_create_by(name: 'machine')  }
    let(:group_name) { 'machine_group'  }
    it 'should create host group given valid name' do
      host_machine.add_group(group_name)
      groups = host_machine.groups.map(&:name)
      expect(groups.include?(group_name)).to eq(true)
      expect(host_machine.valid?).to eq(true)
    end

    it 'should create the group with all downcase' do
      host_machine.add_group(group_name.upcase)
      groups = host_machine.groups.map(&:name)
      expect(groups.include?(group_name.downcase)).to eq(true)
    end

    it 'should not add the group if the name is invalid' do
      host_machine.add_group('')
      groups = host_machine.groups.map(&:name)
      expect(groups.include?("")).to eq(false)
    end
  end
end
