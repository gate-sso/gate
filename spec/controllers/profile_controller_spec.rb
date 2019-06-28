describe ProfileController, type: :controller do
  let!(:admin) { create(:admin_user) }
  let(:user) { create(:user, admin: false) }

  describe '#update' do
    context 'unauthenticated' do
      it 'should return status 302' do
        post :update, params: { id: user.id }

        expect(response).to have_http_status(302)
      end
    end

    context 'authenticated as admin' do
      it 'should update user' do
        new_user = create(:user, active: true, admin: true)
        sign_in admin

        post :update, params: { id: new_user.id, user: { admin: false, active: false } }
        new_user.reload

        expect(new_user).to have_attributes(active: false, admin: false)
      end

      it 'should revoke admin when deactivate user' do
        new_user = create(:user, active: true, admin: true)
        sign_in admin

        post :update, params: { id: new_user.id, user: { active: false } }
        new_user.reload

        expect(new_user).to have_attributes(active: false, admin: false)
      end

      it 'should redirect to user_path after update' do
        sign_in admin

        post :update, params: { id: user.id, user: { admin: false, active: false } }

        expect(response).to redirect_to(user_path)
      end
    end

    context 'authenticated as non admin' do
      it 'should not update user' do
        new_user = create(:user, active: true, admin: true)
        sign_in user

        post :update, params: { id: new_user.id, user: { admin: false, active: false } }
        new_user.reload

        expect(new_user).to have_attributes(active: true, admin: true)
      end
    end
  end
end
