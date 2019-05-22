class PingsController < ApplicationController
  def show
    render plain: 'pong'
  end
end
