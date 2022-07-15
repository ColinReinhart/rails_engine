class Merchant < ApplicationRecord
  has_many :items

  validates_presence_of :name

  def self.find_name(input)
    merchant = Merchant.find_by('name ILIKE ?', "%#{input}%")
    if merchant.nil?
      { data: {} }
    else
      MerchantSerializer.new(merchant)
    end
  end

  def self.find_all_name(input)
    Merchant.where("name ILIKE ?", "%#{input}%")
  end
end
