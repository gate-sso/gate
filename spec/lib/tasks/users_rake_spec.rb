require 'rails_helper'

describe "users:purge_inactive" do
  before(:each) do
    @user = create(:user)
    @user.update!(active: false)
  end

  it "purge users whom have been deactivated for more than certain time" do
    Gate::Application.load_tasks
    @user.update_column(:deactivated_at, Time.now - 16.days)
    Rake::Task['users:purge_inactive'].invoke
    @user.reload
    expect(@user.group_associations.length).to eq 0
  end
end
