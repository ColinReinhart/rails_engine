class Item < ApplicationRecord
  belongs_to :merchant

  has_many :invoice_items
  has_many :invoices, through: :invoice_items

  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :unit_price

  def self.find_all_name(input)
    Item.where("name ILIKE ?", "%#{input}%")
  end

  def self.find_name(input)
    item = Item.find_by('name ILIKE ?', "%#{input}%")
    if item.nil?
      { data: {} }
    else
      ItemSerializer.new(item)
    end
  end
end
