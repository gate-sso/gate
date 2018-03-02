require 'rails_helper'

RSpec.describe GroupsController, type: :controller do

  describe "POST groups/:id/add_user" do
    it 'should add the user to group when the current user is group admin' do
        admin = FactoryBot.create(:user, name: "foobar", user_login_id: "foobar", email: "foobar@foobar.com", admin: 1)
        group = FactoryBot.create(:group)
        sign_in admin

        user = FactoryBot.create(:user, name: "u1", user_login_id: "u1", email: "u1@foobar.com", admin: 0)
        
        post :add_user, id: group.id, user_id: user.id

        expect(GroupAssociation.where({group_id: group.id, user_id: user.id}).count).to eq(1)
    end

    it 'should add the user to group when the current user is not group admin' do
        admin = FactoryBot.create(:user, name: "foobar", user_login_id: "foobar", email: "foobar@foobar.com", admin: 1)
        group = FactoryBot.create(:group)
        GroupAdmin.create(group_id: group.id, user_id: admin.id)

        current_user = FactoryBot.create(:user, name: "u1", user_login_id: "u1", email: "u1@foobar.com", admin: 0)
        sign_in current_user

        user = FactoryBot.create(:user, name: "u2", user_login_id: "u2", email: "u2@foobar.com", admin: 0)
        
        post :add_user, id: group.id, user_id: user.id

        expect(GroupAssociation.where({group_id: group.id, user_id: user.id}).count).to eq(0)
    end

  end
end
