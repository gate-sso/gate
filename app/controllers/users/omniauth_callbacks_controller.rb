class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_action :set_paper_trail_whodunnit
  def google_oauth2
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    #
    data = request.env["omniauth.auth"]
    domain = data["info"]["email"].split("@").last

    return render :text => "Your domain is unauthorized", :status => :unauthorized if !User.valid_domain? domain

    @user = User.from_omniauth(data)

    if @user.persisted?
      if @user.auth_key.blank?
        @user.auth_key = ROTP::Base32.random_base32
        totp = ROTP::TOTP.new(@user.auth_key)
        @user.provisioning_uri = totp.provisioning_uri @user.email
        @user.save!
      end
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end
