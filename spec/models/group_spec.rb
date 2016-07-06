require 'rails_helper'
GID_CONSTANT = 9000
RSpec.describe Group, type: :model do

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
end
