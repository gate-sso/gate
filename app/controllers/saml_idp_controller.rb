class SamlIdpController < SamlIdp::IdpController
  before_filter :authenticate_user!, :except => [:create] unless Rails.env.development?
  def show
    if current_user.admin?
      render xml: SamlIdp.metadata.signed
    else
      respond_to do |format|
        format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
        format.xml  { head :not_found }
        format.any  { head :not_found }
      end
    end
  end

  def create
    unless params[:email].blank? && params[:password].blank?
      person = idp_authenticate(params[:email], params[:password])
      if person.nil?
        @saml_idp_fail_msg = "Incorrect email or password."
      else
        @saml_response = idp_make_saml_response(person)
        render :template => "saml_idp/idp/saml_post", :layout => false
        return
      end
    end
    render :template => "saml_idp/new"
  end

  def idp_authenticate(username, token)
   if User.find_and_check_user username, token
      return User.get_user(username)
    end
    return false
  end
  private :idp_authenticate

  def idp_make_saml_response(found_user)
    encode_response found_user
  end
  private :idp_make_saml_response
end
