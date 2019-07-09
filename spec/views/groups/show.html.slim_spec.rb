RSpec.describe 'groups/show', type: :view do
  let(:admin) { create(:admin_user) }
  let(:group) { create(:group) }

  context 'authorized as admin' do
    it 'should renders form to add user to group' do
      sign_in admin
      assign(:group, group)
  
      render
  
      assert_select 'form[action=?][method=?]', add_user_to_group_path(group.id), 'post' do
        assert_select 'input#add_user_user_id[name=user_id]'
        assert_select 'input#expiration_date[name=expiration_date][type=date]'
      end
    end
  end
end
