class SamlController < ApplicationController
  include SamlIdp::Controller

  # RESPONSE_EXPIRY = Governor::Config[:app, :saml_idp, :response_expiry].to_i

  def show
    render :xml => SamlIdp.metadata.signed
  end
end
