require 'rails_helper'

RSpec.describe HostMachinesController, type: :controller do
  let(:user) do
    create(:user, name: 'foobar', user_login_id: 'foobar', email: 'foobar@foobar.com')
  end
  describe 'Search for Hosts' do
    it 'should return hosts according to supplied search string' do
      sign_in user
      host_machines = create_list(:host_machine, 3)
      get :search, params: { q: 'host' }
      expect(response.body).to eq(host_machines.map { |m| { id: m.id, name: m.name } }.to_json)
    end
  end

  describe 'PATCH #update' do
    context 'authenticated as admin' do
      it 'should update requested host machine' do
        host_machine = create(:host_machine, default_admins: true)
        sign_in user
        patch :update, params: { id: host_machine.id, host_machine: { default_admins: false } }
        host_machine.reload
        expect(host_machine.default_admins). to be false
      end
    end

    context 'authenticated as non admin' do
      it 'should not update requested host machine' do
        create(:user)
        non_admin = create(:user, admin: false)
        host_machine = create(:host_machine, default_admins: true)
        sign_in non_admin
        patch :update, params: { id: host_machine.id, host_machine: { default_admins: false } }
        host_machine.reload
        expect(host_machine.default_admins). to be true
      end

      it 'redirect to host machines path' do
        create(:user)
        non_admin = create(:user, admin: false)
        host_machine = create(:host_machine, default_admins: true)
        sign_in non_admin
        patch :update, params: { id: host_machine.id, host_machine: { default_admins: false } }
        expect(response).to redirect_to(host_machines_path)
      end
    end
  end

  describe 'DELETE #delete_group' do
    context 'authenticated as admin' do
      it 'should delete group from host machine' do
        admin = create(:user)
        host_machine = create(:host_machine)
        group = create(:group)
        host_machine.groups << group
        sign_in admin
        delete :delete_group, params: { id: host_machine.id, group_id: group.id }
        host_machine.reload
        expect(host_machine.groups.count).to eq(0)
      end
    end

    context 'authenticated as non admin' do
      it 'should not delete group from host machine' do
        create(:user)
        non_admin = create(:user, admin: false)
        host_machine = create(:host_machine)
        group = create(:group)
        host_machine.groups << group
        sign_in non_admin
        delete :delete_group, params: { id: host_machine.id, group_id: group.id }
        host_machine.reload
        expect(host_machine.groups.count).to eq(1)
      end

      it 'should redirect to host machines path' do
        create(:user)
        non_admin = create(:user, admin: false)
        host_machine = create(:host_machine)
        group = create(:group)
        host_machine.groups << group
        sign_in non_admin
        delete :delete_group, params: { id: host_machine.id, group_id: group.id }
        expect(response).to redirect_to(host_machines_path)
      end

      it 'should flash notice message unauthorized access' do
        create(:user)
        non_admin = create(:user, admin: false)
        host_machine = create(:host_machine)
        group = create(:group)
        host_machine.groups << group
        sign_in non_admin
        delete :delete_group, params: { id: host_machine.id, group_id: group.id }
        expect(flash[:notice]).to eq('Unauthorized access')
      end
    end
  end
end
