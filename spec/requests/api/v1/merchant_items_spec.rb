require 'rails_helper'

RSpec.describe "Merchant items API" do
  it "returns all that merchants items when a valid id is given" do
    merch_id = create(:merchant).id

    create_list(:item, 6, merchant_id: merch_id)

    get "/api/v1/merchants/#{merch_id}/items"

    expect(response.status).to eq(200)

    parsed = JSON.parse(response.body, symbolize_names: true)

    expect(parsed).to have_key(:data)

    items = parsed[:data]

    items.each do |item|
      expect(item).to have_key(:id)
      expect(item).to have_key(:type)
      expect(item).to have_key(:attributes)

      expect(item[:id]).to be_a(String)
      expect(item[:type]).to be_a(String)
      expect(item[:attributes]).to be_a(Hash)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes]).to have_key(:merchant_id)

      expect(item[:attributes][:name]).to be_a(String)
      expect(item[:attributes][:description]).to be_a(String)
      expect(item[:attributes][:unit_price]).to be_a(Float)
      expect(item[:attributes][:merchant_id]).to be_a(Integer)
    end
  end

  it "gets a 404 error when no merchant id is provided" do
    get "/api/v1/merchants/1/items"

    expect(response.status).to eq(404)
  end
end
