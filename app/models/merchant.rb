class Merchant < ApplicationRecord
  has_many :items

  validates_presence_of :name

  def self.find_name(input)
    merchant = Merchant.find_by('name ILIKE ?', "%#{input}%")
    MerchantSerializer.new(merchant)
  end
end
