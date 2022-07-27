class Merchant < ApplicationRecord
  has_many :items
  has_many :invoices
  has_many :invoice_items, through: :invoices
  has_many :transactions, through: :invoices
  has_many :customers, through: :invoices

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

  def self.top_merchants_by_revenue(quantity)
    joins(invoices: [:invoice_items, :transactions]).where(transactions: {result: 'success'}, invoices: {status: 'shipped'}).select(:name, :id, 'SUM(invoice_items.quantity * invoice_items.unit_price) as revenue').group(:id).order(revenue: :desc).limit(quantity)
  end

  def self.top_merchants_by_items_sold(input)
    joins(invoices: [:invoice_items, :transactions]).where(transactions: {result: 'success'}, invoices: {status: 'shipped'}).select(:name, :id, 'SUM(invoice_items.quantity) as item_count').group(:id).order(item_count: :desc).limit(input)
  end
end
