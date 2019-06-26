describe ProfileController, type: :controller do
  let(:user) { create(:user) }
  describe '#update' do
    context 'unauthenticated' do
      it 'should return status 302' do
        post :update, params: { id: user.id }

        expect(response).to have_http_status(302)
      end
    end
  end
end
