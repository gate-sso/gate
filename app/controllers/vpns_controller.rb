class VpnsController < ApplicationController
  before_action :set_paper_trail_whodunnit
  before_action :set_vpn, only: [:show, :edit, :update, :destroy]

  def index
    @vpns = Vpn.all
  end

  def create
    puts params
    puts vpn_params

    @vpn = Vpn.new(vpn_params)
    respond_to do |format|
      if @vpn.save
        format.html { redirect_to vpns_path, notice: 'Vpn was successfully added.' }
        format.json { render status: :created, json: "#{@vpn.name}host created" }
      else
        format.html { redirect_to vpns_path, notice: "Can't save '#{vpn_params[:name]}'" }
        format.json { render status: :error, json: "#{@vpn.name} not created" }
      end
    end
  end

  def new 
    @vpn = Vpn.new
  end

  private
  def set_vpn
    @vpn = Vpn.find(params[:id])
  end

  def vpn_params
    params.require(:vpn).permit(:name, :host_name, :url, :ip_address)
  end
end
