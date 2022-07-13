require 'rails_helper'

describe "Merchant API" do
  it "can get all merchants" do
    create_list(:merchant, 3)

    get '/api/v1/merchants'

    expect(response).to be_successful

    parsed = JSON.parse(response.body, symbolize_names: true)

    expect(parsed).to have_key(:data)
    expect(parsed[:data]).to be_a(Array)

    merchants = parsed[:data]

    expect(merchants.count).to eq(3)

    merchants.each do |merchant|
# require "pry"; binding.pry
      expect(merchant).to have_key(:id)
       expect(merchant[:id]).to be_an(String)

      expect(merchant).to have_key(:attributes)
      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)

      expect(merchant).to have_key(:type)
      expect(merchant[:type]).to eq('merchant')
    end
  end

  it "can retrieve single merchant" do
    merchant = create(:merchant).id

    get "/api/v1/merchants/#{merchant}"
    expect(response.status).to eq(200)

    parsed_body = JSON.parse(response.body, symbolize_names: true)

    expect(parsed_body).to have_key(:data)
    expect(parsed_body[:data]).to be_a(Hash)

    merchant_data = parsed_body[:data]

    expect(merchant_data).to have_key(:id)
    expect(merchant_data).to have_key(:type)
    expect(merchant_data).to have_key(:attributes)

    expect(merchant_data[:id]).to be_a(String)
    expect(merchant_data[:type]).to eq('merchant')
    expect(merchant_data[:attributes]).to be_a(Hash)

    merchant_name = merchant_data[:attributes]

    expect(merchant_name).to have_key(:name)
    expect(merchant_name[:name]).to be_a(String)

    expect(merchant_name).to_not have_key(:created_at)
    expect(merchant_name).to_not have_key(:updated_at)
  end
end
