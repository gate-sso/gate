class VpnsController < ApplicationController
  before_action :authorize_user
  before_action :set_vpn, only: %i[show edit update destroy user_associated_groups]

  def destroy; end
end

#TODO fix this in future. This is something not great.
class VpnDomainNameServersController < ApplicationController
end
