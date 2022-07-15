class Api::V1::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]),  status: :ok)
  end

  def create
    item = Item.create(item_params)
    if item.save
      render json: ItemSerializer.new(item), status: 201
    else
      render json: { :message => "Item Not Created"}, status: 400
    end
  end

  def destroy
    if Item.exists?(params[:id])
      Item.destroy(params[:id])
    else
      render status:404
    end
  end

  def update
    if Item.exists?(params[:id])
      item = Item.find(params[:id])
      item.update(item_params)
    else
      render status: 404
    end
  end

  def find_all
    if params[:name]
      if params[:name] == ""
        render status: 400
      else
        find_names = Item.find_all_name(params[:name])
        render json: ItemSerializer.new(find_names)
      end
    elsif params[:min_price] && params[:max_price]
      range = Item.within_price_range(params[:min_price], params[:max_price])
      render json: ItemSerializer.new(range)
    elsif params[:min_price]
      min = Item.above_price(params[:min_price])
      render json: ItemSerializer.new(min)
    elsif params[:max_price]
      max = Item.under_price(params[:max_price])
      render json: ItemSerializer.new(max)
    else
      render status: 400
    end
  end

  def find
    render json: Item.find_name(params[:name])
  end

  private
    def item_params
      params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
    end
end
