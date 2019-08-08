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
  end
end
