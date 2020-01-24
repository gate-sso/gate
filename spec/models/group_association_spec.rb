require 'rails_helper'

describe GroupAssociation, type: :model do
  describe '.revoke_expired' do
    let(:user) { create(:user) }
    let(:group) { create(:group) }

    context 'when found expired associations' do
      it 'should revoke associations' do
        group.add_user_with_expiration(user, Date.today - 1)

        GroupAssociation.revoke_expired

        expired_association = GroupAssociation.where('expiration_date < ?', Date.today).count
        expect(expired_association).to eq 0
      end

      it 'should create paper trail with event destroy' do
        group_association = group.add_user_with_expiration(user, Date.today - 1)

        GroupAssociation.revoke_expired

        versions = PaperTrail::Version.
          with_item_keys(GroupAssociation.name, group_association.id).
          where(event: 'destroy')
        expect(versions.length).to eq(1)
      end
    end

    it 'should not revoke associations that not expired yet' do
      group.add_user_with_expiration(user, Date.today)

      GroupAssociation.revoke_expired

      unexpired_association = GroupAssociation.where('expiration_date >= ?', Date.today).count
      expect(unexpired_association).to eq 1
    end
  end
end
