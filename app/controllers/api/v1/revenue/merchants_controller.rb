class Api::V1::Revenue::MerchantsController < ApplicationController
  def index
    merchants = Merchant.top_merchants_by_revenue(params[:quantity])
    render json: MerchantNameRevenueSerializer.new(merchants)
  end
end
