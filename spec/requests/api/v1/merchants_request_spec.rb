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

  it "can find a merchant by name" do
    merch_1 = Merchant.create!(name: "Colin")
    merch_2 = Merchant.create!(name: "Burke")
    merch_3 = Merchant.create!(name: "Reinhart")

    headers = { "CONTENT_TYPE" => 'application/json'}
    get "/api/v1/merchants/find", headers: headers, params: { name: 'Col'}

    expect(response.status).to eq(200)

    parsed = JSON.parse(response.body, symbolize_names: true)

    expect(parsed).to have_key(:data)
    expect(parsed).to be_a(Hash)

    expect(parsed[:data]).to have_key(:id)
    expect(parsed[:data]).to have_key(:type)
    expect(parsed[:data]).to have_key(:attributes)

    expect(parsed[:data][:id]).to be_a(String)
    expect(parsed[:data][:type]).to be_a(String)
    expect(parsed[:data][:attributes]).to be_a(Hash)

    name = parsed[:data][:attributes][:name]

    expect(name).to eq("Colin")
  end

  it "can find all merchants by name fragment" do
    merch_1 = Merchant.create!(name: "Colin's Clothes")
    merch_2 = Merchant.create!(name: "Colin's Hats")
    merch_3 = Merchant.create!(name: "Bob's Hats")

    headers = { "CONTENT_TYPE" => 'application/json'}
    get "/api/v1/merchants/find_all", headers: headers, params: { name: 'Col'}

    expect(response.status).to eq(200)

    parsed = JSON.parse(response.body, symbolize_names: true)

    expect(parsed).to have_key(:data)

    array = parsed[:data]

    expect(array).to be_a(Array)
    expect(array.first).to have_key(:id)
    expect(array.first).to have_key(:type)
    expect(array.first).to have_key(:attributes)

    expect(array.first[:id]).to be_a(String)
    expect(array.first[:type]).to be_a(String)
    expect(array.first[:attributes]).to be_a(Hash)

    merchant = array.first[:attributes]

    expect(merchant).to have_key(:name)
    expect(merchant[:name]).to eq("Colin's Clothes")
  end

  it "returns empty api if merchant not found" do
    merch_1 = Merchant.create!(name: "Colin's Clothes")

    headers = { "CONTENT_TYPE" => 'application/json'}
    get "/api/v1/merchants/find_all", headers: headers, params: { name: '123'}

    expect(response.status).to eq(200)

    parsed = JSON.parse(response.body, symbolize_names: true)

    expect(parsed).to eq({:data=>[]})
  end
end
