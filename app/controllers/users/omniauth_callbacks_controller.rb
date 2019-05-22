class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_action :set_paper_trail_whodunnit
  def google_oauth2
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    #
    data = request.env['omniauth.auth']
    domain = data['info']['email'].split('@').last

    unless User.valid_domain? domain
      return render plain: 'Your domain is unauthorized', status: :unauthorized
    end

    @user = User.create_user(data.info['name'], data.info['email'])

    if @user.persisted?
      @user.generate_two_factor_auth
      sign_in_and_redirect @user, event: :authentication
    else
      session['devise.google_data'] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end
end
