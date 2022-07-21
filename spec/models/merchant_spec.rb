require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'relationships' do
    it { should have_many(:items) }
  end

  describe 'model methods' do
    it '#find_name' do
      merch_1 = Merchant.create!(name: "Colin")
      merch_2 = Merchant.create!(name: "Burke")
      merch_3 = Merchant.create!(name: "Reinhart")

      merch = Merchant.find_name('Col')

      name = JSON.parse(merchant.to_json, symbolize_names: true) [:data][:attributes][:name]

      expect(name).to eq("Colin")
    end
  end
end
