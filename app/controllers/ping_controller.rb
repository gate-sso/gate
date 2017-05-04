class PingController < ApplicationController
  def ping
    render json: "", status: 200
  end
end
