require 'rails_helper'
GID_CONSTANT = 9000
RSpec.describe Group, type: :model do
  context 'validate uniqueness' do
    subject { FactoryGirl.create(:group) }
    it { should validate_uniqueness_of(:name).ignoring_case_sensitivity }
  end

  it "should save gid after create" do
    group = create(:group)
    expect(group.gid.to_i).to eq(group.id + GID_CONSTANT);
  end

  it "should provide name response" do
    group = create(:group)
    user = create(:user)
    group_response = Group.get_name_response "people"
    expect(group_response.count).to eq(4)
    expect(group_response[:gr_mem].count).to eq(1)
    expect(group_response[:gr_mem][0]).to eq("test1")
  end

  it "should provide gid response" do
    group = create(:group)
    user = create(:user)
    group_response = Group.get_gid_response group.gid
    expect(group_response.count).to eq(4)
    expect(group_response[:gr_name]).to eq("people")
  end

  it "should provide correct gid response even if we add a machine to grouo" do
    group = create(:group)
    user = create(:user)
    host_machine = create(:host_machine)
    host_machine.groups << group
    host_machine.save!
    group_response = Group.get_name_response "people"
    expect(group.host_machines.count).to eq(1)
    expect(group_response.count).to eq(4)
    expect(group_response[:gr_mem].count).to eq(1)
    expect(group_response[:gr_mem][0]).to eq(user.user_login_id)

    host_response = HostMachine.get_group_response host_machine.name

    expect(host_machine.groups.count).to eq(1)
    expect(host_response[:groups].count).to eq(1)
    expect(host_response[:groups][0]).to eq(group.name)
  end
end
