require "rails_helper"

RSpec.describe "Item Merchant API" do
  it "can fetch a merchant through the item" do
    merch_id = create(:merchant).id
    item = create(:item, merchant_id: merch_id)

    get "/api/v1/items/#{item.id}/merchant"

    expect(response.status).to eq(200)

    parsed = JSON.parse(response.body, symbolize_names: true)
    expect(parsed).to have_key(:data)

    merchant = parsed[:data]

    expect(merchant).to have_key(:id)
    expect(merchant).to have_key(:type)
    expect(merchant).to have_key(:attributes)

    expect(merchant[:id]).to be_a(String)
    expect(merchant[:type]).to eq('merchant')
    expect(merchant[:attributes]).to be_a(Hash)

    name = merchant[:attributes]

    expect(name[:name]).to be_a(String)
  end
end
