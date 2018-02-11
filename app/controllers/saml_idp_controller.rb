class SamlIdpController < SamlIdp::IdpController
  before_filter :is_saml_enabled, :except => [:add_saml_sp, :get_saml_sp]
  before_filter :authenticate_user!, :except => [:create, :add_saml_sp, :get_saml_sp] unless Rails.env.development?

  def show
    if current_user.admin?
      render xml: SamlIdp.metadata.signed
    else
      respond_to do |format|
        format.html {render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found}
        format.xml {head :not_found}
        format.any {head :not_found}
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

  def add_saml_sp
    if AccessToken.valid_token(params[:access_token])
      @sp = SamlServiceProvider.find_or_create_by(:name => params[:name], :sso_url => params[:sso_url], :metadata_url => params[:metadata_url])
      update_saml_idp_config
      render json: @sp, status: :ok
    else
      render json: {"error": "Unauthorized user"}, status: :unauthorized
    end
  end

  def update_saml_idp_config
    SamlIdp.configure do |config|
      service_providers = {}
      SamlServiceProvider.find_each do |sp|
        service_providers[sp.sso_url] = {
            :fingerprint => Figaro.env.GATE_SAML_IDP_FINGERPRINT,
            :metadata_url => sp.metadata_url
        }
      end
      config.service_provider.finder = ->(issuer_or_entity_id) do
        service_providers[issuer_or_entity_id]
      end
    end
  end

  private :update_saml_idp_config

  def get_saml_sp
    if AccessToken.valid_token(params[:access_token])
      @sp = SamlServiceProvider.where(name: params[:name]).first
      if @sp
        render json: @sp, status: :ok
      else
        render json: {"error": "service provider with name #{params[:name]} not found"}, status: :not_found
      end
    else
      render json: {"error": "Unauthorized user"}, status: :unauthorized
    end
  end

  def is_saml_enabled
    if Figaro.env.ENABLE_SAML
      return true
    else
      respond_to do |format|
        format.html {render :file => "#{Rails.root}/public/saml_not_enabled", :layout => false, :status => :not_found}
        format.xml {head :not_found}
        format.any {head :not_found}
      end
    end
  end

  private :is_saml_enabled
end
