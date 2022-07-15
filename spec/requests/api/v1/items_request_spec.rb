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

  it "can update item" do
    merch_id = create(:merchant).id
    item = create(:item, merchant_id: merch_id)

    expect(item.name).to_not eq("Item Name")
    expect(item.description).to include("Chuck")
    expect(item.unit_price).to_not eq(314.15)

    params = {
      name: "Item Name",
      description: "Item Description",
      unit_price: 314.15,
      merchant_id: merch_id
    }

    headers = { 'CONTENT_TYPE' => 'application/json' }

    put "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item: params)

    expect(Item.first.name).to eq("Item Name")
    expect(Item.first.description).to eq("Item Description")
    expect(Item.first.unit_price).to eq(314.15)
  end

  it "create sad path" do
    merch_id = create(:merchant).id

    params = {
      name: "",
      description: "Item Description",
      unit_price: 314.15,
      merchant_id: merch_id
    }

    headers = { 'CONTENT_TYPE' => 'application/json' }

    post '/api/v1/items', headers: headers, params: JSON.generate(item: params)

    expect(response.status).to eq(400)
  end

  it "update sad paths" do
    merch_id = create(:merchant).id
    item = create(:item, merchant_id: merch_id)

    expect(item.name).to_not eq("Item Name")
    expect(item.description).to include("Chuck")
    expect(item.unit_price).to_not eq(314.15)

    params = {
      name: "Item Name",
      description: "Item Description",
      unit_price: 314.15,
      merchant_id: merch_id
    }

    headers = { 'CONTENT_TYPE' => 'application/json' }

    put "/api/v1/items/1", headers: headers, params: JSON.generate(item: params)

    expect(response.status).to eq(404)
  end

  it "can find all items by name fragment" do
    merch_id = create(:merchant).id
    item_1 = Item.create!(name: "Colin's hat", description: "The hat Colin is wearing right now", unit_price: 1000.00, merchant_id: merch_id )
    item_2 = Item.create!(name: "Colin's shirt", description: "The shirt Colin is wearing right now", unit_price: 1020.00, merchant_id: merch_id )
    item_3 = Item.create!(name: "Bob's hat", description: "The hat Bob is wearing right now", unit_price: 1000.00, merchant_id: merch_id )

    headers = { "CONTENT_TYPE" => 'application/json'}
    get "/api/v1/items/find_all", headers: headers, params: { name: "Colin's"}

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

    expect(array.last[:attributes][:name]).to eq("Colin's shirt")
  end

  it "can find one item by name fragment" do
    merch_1 = Merchant.create!(name: "Colin")
    item_1 = Item.create!(name: "Colin's hat", description: "The hat of Colin", unit_price: 10.00, merchant_id: merch_1.id )
    item_2 = Item.create!(name: "Colin's shirt", description: "The shirt of Colin", unit_price: 15.00, merchant_id: merch_1.id )
    item_3 = Item.create!(name: "Bob's hat", description: "The hat of Bob", unit_price: 20.00, merchant_id: merch_1.id )

    headers = { "CONTENT_TYPE" => 'application/json'}
    get "/api/v1/items/find", headers: headers, params: { name: 'Col'}

    expect(response.status).to eq(200)

    parsed = JSON.parse(response.body, symbolize_names: true)

    expect(parsed).to have_key(:data)

    item = parsed[:data]

    expect(item).to have_key(:id)
    expect(item).to have_key(:type)
    expect(item).to have_key(:attributes)

    expect(item[:id]).to be_a(String)
    expect(item[:type]).to be_a(String)
    expect(item[:attributes]).to be_a(Hash)

    attributes = item[:attributes]

    expect(attributes).to have_key(:name)
    expect(attributes).to have_key(:description)
    expect(attributes).to have_key(:unit_price)
    expect(attributes).to have_key(:merchant_id)

    expect(attributes[:name]).to eq("Colin's hat")
    expect(attributes[:description]).to eq("The hat of Colin")
    expect(attributes[:unit_price]).to eq(10.0)
  end

  it "can find items within a price range" do
    merch_1 = Merchant.create!(name: "Colin")
    item_1 = Item.create!(name: "Colin's hat", description: "The hat of Colin", unit_price: 10.00, merchant_id: merch_1.id )
    item_2 = Item.create!(name: "Colin's shirt", description: "The shirt of Colin", unit_price: 15.00, merchant_id: merch_1.id )
    item_3 = Item.create!(name: "Bob's hat", description: "The hat of Bob", unit_price: 20.00, merchant_id: merch_1.id )

    headers = { "CONTENT_TYPE" => 'application/json'}
    get "/api/v1/items/find_all", headers: headers, params: { min_price: 9.00, max_price: 16.00 }

    expect(response.status).to eq(200)

    parsed = JSON.parse(response.body, symbolize_names: true)

    expect(parsed).to have_key(:data)
    expect(parsed[:data]).to be_a(Array)

    array = parsed[:data]

    expect(array.length).to eq(2)

    array.each do |item|
      expect(item).to have_key(:id)
      expect(item).to have_key(:type)
      expect(item).to have_key(:attributes)

      expect(item[:id]).to be_a(String)
      expect(item[:type]).to be_a(String)
      expect(item[:attributes]).to be_a(Hash)
    end

    first_item = array.first[:attributes]

    expect(first_item).to have_key(:name)
    expect(first_item).to have_key(:description)
    expect(first_item).to have_key(:unit_price)

    expect(first_item[:name]).to eq("Colin's hat")
    expect(first_item[:description]).to eq("The hat of Colin")
    expect(first_item[:unit_price]).to eq(10.00)
  end

  it "can find an item over a price" do
    merch_1 = Merchant.create!(name: "Colin")
    item_1 = Item.create!(name: "Colin's hat", description: "The hat of Colin", unit_price: 10.00, merchant_id: merch_1.id )
    item_2 = Item.create!(name: "Colin's shirt", description: "The shirt of Colin", unit_price: 15.00, merchant_id: merch_1.id )
    item_3 = Item.create!(name: "Bob's hat", description: "The hat of Bob", unit_price: 20.00, merchant_id: merch_1.id )

    headers = { "CONTENT_TYPE" => 'application/json'}
    get "/api/v1/items/find_all", headers: headers, params: { min_price: 10.00 }

    expect(response.status).to eq(200)

    parsed = JSON.parse(response.body, symbolize_names: true)

    expect(parsed).to have_key(:data)
    expect(parsed[:data]).to be_a(Array)

    array = parsed[:data]

    expect(array.length).to eq(2)

    array.each do |item|
      expect(item).to have_key(:id)
      expect(item).to have_key(:type)
      expect(item).to have_key(:attributes)

      expect(item[:id]).to be_a(String)
      expect(item[:type]).to be_a(String)
      expect(item[:attributes]).to be_a(Hash)
    end

    first_item = array.first[:attributes]

    expect(first_item).to have_key(:name)
    expect(first_item).to have_key(:description)
    expect(first_item).to have_key(:unit_price)

    expect(first_item[:name]).to eq("Colin's shirt")
    expect(first_item[:description]).to eq("The shirt of Colin")
    expect(first_item[:unit_price]).to eq(15.00)
  end

  it "can find an item under a price" do
    merch_1 = Merchant.create!(name: "Colin")
    item_1 = Item.create!(name: "Colin's hat", description: "The hat of Colin", unit_price: 10.00, merchant_id: merch_1.id )
    item_2 = Item.create!(name: "Colin's shirt", description: "The shirt of Colin", unit_price: 15.00, merchant_id: merch_1.id )
    item_3 = Item.create!(name: "Bob's hat", description: "The hat of Bob", unit_price: 20.00, merchant_id: merch_1.id )

    headers = { "CONTENT_TYPE" => 'application/json'}
    get "/api/v1/items/find_all", headers: headers, params: { max_price: 16.00 }

    expect(response.status).to eq(200)

    parsed = JSON.parse(response.body, symbolize_names: true)

    expect(parsed).to have_key(:data)
    expect(parsed[:data]).to be_a(Array)

    array = parsed[:data]

    expect(array.length).to eq(2)

    array.each do |item|
      expect(item).to have_key(:id)
      expect(item).to have_key(:type)
      expect(item).to have_key(:attributes)

      expect(item[:id]).to be_a(String)
      expect(item[:type]).to be_a(String)
      expect(item[:attributes]).to be_a(Hash)
    end

    first_item = array.first[:attributes]

    expect(first_item).to have_key(:name)
    expect(first_item).to have_key(:description)
    expect(first_item).to have_key(:unit_price)

    expect(first_item[:name]).to eq("Colin's hat")
    expect(first_item[:description]).to eq("The hat of Colin")
    expect(first_item[:unit_price]).to eq(10.00)
  end
end
