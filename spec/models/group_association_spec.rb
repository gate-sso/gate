describe GroupAssociation, type: :model do
  describe '.revoke_expired' do
    it 'should revoke associations that expired yesterday' do
      user = create(:user)
      group = create(:group)
      group.add_user_with_expiration(user, Date.today - 1)

      GroupAssociation.revoke_expired

      expired_association = GroupAssociation.where('expiration_date < ?', Date.today).count
      expect(expired_association).to eq 0
    end

    it 'should not revoke associations that not expired yet' do
      user = create(:user)
      group = create(:group)
      group.add_user_with_expiration(user, Date.today)

      GroupAssociation.revoke_expired

      unexpired_association = GroupAssociation.where('expiration_date >= ?', Date.today).count
      expect(unexpired_association).to eq 1
    end
  end
end
