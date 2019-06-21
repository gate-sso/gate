require 'rails_helper'
GID_CONSTANT = 9000
RSpec.describe Group, type: :model do
  context 'validate uniqueness' do
    subject { FactoryBot.create(:group) }
    it { should validate_uniqueness_of(:name).ignoring_case_sensitivity }
  end

  it 'should save gid after create' do
    group = create(:group)
    expect(group.gid.to_i).to eq(group.id + GID_CONSTANT)
  end

  it 'should provide name response' do
    user = create(:user)
    group_response = Group.get_name_response user.groups.first.name
    expect(group_response.count).to eq(4)
    expect(group_response[:gr_mem].count).to eq(1)
    expect(group_response[:gr_mem][0]).to eq(user.user_login_id)
  end

  it 'should provide gid response' do
    group = create(:group)
    group_response = Group.get_gid_response group.gid
    expect(group_response.count).to eq(4)
    expect(group_response[:gr_name]).to eq(group.name)
  end

  it 'should provide correct gid response even if we add a machine to group' do
    group = create(:group)
    user = create(:user)
    user.groups << group
    user.save
    host_machine = create(:host_machine)
    host_machine.groups << group
    host_machine.save!
    group_response = Group.get_name_response group.name
    expect(group.host_machines.count).to eq(1)
    expect(group_response.count).to eq(4)
    expect(group_response[:gr_mem].count).to eq(1)
    expect(group_response[:gr_mem][0]).to eq(user.user_login_id)

    host_response = HostMachine.get_group_response host_machine.name
    expect(host_machine.groups.count).to eq(1)
    expect(host_response[:groups].count).to eq(1)
    expect(host_response[:groups][0]).to eq(group.name)
  end

  describe 'add_user' do
    let(:user) { create(:user) }
    let(:group) { create(:group) }

    it 'add user to the group' do
      group.add_user(user.id)
      expect(group.users.map(&:id).include?(user.id)).to eq(true)
    end

    it 'not add user if already added to the group' do
      group.add_user(user.id)
      group.add_user(user.id)
      expect(group.users.where(id: user.id).size).to eq(1)
    end
  end

  describe 'remove_user' do
    let(:user) { create(:user) }
    let(:group) { create(:group) }

    it 'removes users from the group' do
      group.add_user(user.id)
      group.remove_user(user.id)
      expect(group.users.map(&:id).include?(user.id)).to eq(false)
    end
  end
end
