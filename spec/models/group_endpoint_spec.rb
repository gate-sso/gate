require 'rails_helper'

describe GroupEndpoint, type: :model do
  describe 'validations' do
    context 'given duplicate group with endpoint' do
      it 'should not valid' do
        group = create(:group)
        endpoint = create(:endpoint)
        GroupEndpoint.create(group: group, endpoint: endpoint)
        group_endpoint = GroupEndpoint.new(group: group, endpoint: endpoint)
        expect(group_endpoint).not_to be_valid
      end
    end
  end
end
