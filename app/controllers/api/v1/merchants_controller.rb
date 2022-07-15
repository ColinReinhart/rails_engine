class Api::V1::MerchantsController < ApplicationController
  def index
    render json: MerchantSerializer.new(Merchant.all)
  end

  def show
    render json: MerchantSerializer.new(Merchant.find(params[:id]))
  end

  def find
    render json: Merchant.find_name(params[:name])
  end

  def find_all
    find_names = Merchant.find_all_name(params[:name])
    render json: MerchantSerializer.new(find_names)
  end

end
