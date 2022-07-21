class Item < ApplicationRecord
  before_destroy :destroy_invoices

  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items
  has_many :transactions, through: :invoices
  has_many :customers, through: :transactions

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

  def self.within_price_range(min, max)
    Item.where( unit_price: min..max )
  end

  def self.above_price(min)
    Item.where( 'unit_price > ?', min)
  end

  def self.under_price(max)
    Item.where( 'unit_price < ?', max)
  end

  private
    def destroy_invoices
      invoices.each do |invoice|
        invoice.destroy if invoice.items.length == 1
      end
    end
end
