require 'rails_helper'

RSpec.describe "Items API" do
  it "sends all items" do
    merchant_1 = create(:merchant).id
    merchant_2 = create(:merchant).id
    create_list(:item, 5, merchant_id: merchant_1)

    create_list(:item, 6, merchant_id: merchant_2)

    get '/api/v1/items'

    expect(response.status).to eq(200)

    parsed = JSON.parse(response.body, symbolize_names: true)

    expect(parsed).to have_key(:data)
    expect(parsed[:data]).to be_a(Array)

    items = parsed[:data]

    expect(items.count).to eq(11)

    items.each do |item|

      expect(item).to have_key(:id)
      expect(item).to have_key(:type)
      expect(item).to have_key(:attributes)

      expect(item[:id]).to be_a(String)
      expect(item[:type]).to be_a(String)
      expect(item[:attributes]).to be_a(Hash)
    end
  end

  it "can retrieve single item" do
    id = create(:merchant).id
    item = create(:item, merchant_id: id).id

    get "/api/v1/items/#{item}"
    expect(response.status).to eq(200)

    parsed_body = JSON.parse(response.body, symbolize_names: true)

    expect(parsed_body).to have_key(:data)
    expect(parsed_body[:data]).to be_a(Hash)

    item_data = parsed_body[:data]

    expect(item_data).to have_key(:id)
    expect(item_data).to have_key(:type)
    expect(item_data).to have_key(:attributes)

    expect(item_data[:id]).to be_a(String)
    expect(item_data[:type]).to eq('item')
    expect(item_data[:attributes]).to be_a(Hash)

    item_name = item_data[:attributes]

    expect(item_name).to have_key(:name)
    expect(item_name[:name]).to be_a(String)

    expect(item_name).to_not have_key(:created_at)
    expect(item_name).to_not have_key(:updated_at)
  end

  it "can create item" do
    merch_id = create(:merchant).id

    params = {
      name: "Item Name",
      description: "Item Description",
      unit_price: 314.15,
      merchant_id: merch_id
    }

    headers = { 'CONTENT_TYPE' => 'application/json' }

    post '/api/v1/items', headers: headers, params: JSON.generate(item: params)

    expect(response.status).to eq(201)

    item = Item.last

    expect(item.name).to eq("Item Name")
    expect(item.description).to eq("Item Description")
    expect(item.unit_price).to eq(314.15)
    expect(item.merchant_id).to eq(merch_id)
  end

  it "can delete an item" do
    merch_id = create(:merchant).id
    item = create(:item, merchant_id: merch_id)

    get '/api/v1/items'

    parsed = JSON.parse(response.body, symbolize_names: true)

    expect(parsed).to have_key(:data)
    expect(parsed[:data]).to be_a(Array)

    items = parsed[:data]

    expect(Item.all.count).to eq(1)

    delete "/api/v1/items/#{item.id}"

    expect(Item.all.count).to eq(0)
  end

  it "sends 404 error if item does not exist" do
    delete "/api/v1/items/1"

    expect(response.status).to eq(404)
  end
end
