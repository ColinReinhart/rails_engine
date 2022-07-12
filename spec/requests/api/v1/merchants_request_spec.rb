require 'rails_helper'

describe "Merchant API" do
  it "happy path, all merchants returned are same as in db" do
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

      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)
    end
  end
end
