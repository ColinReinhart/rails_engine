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
      if item.save
        render json: ItemSerializer.new(item)
      else
        render status: 404
      end
    else
      render status: 404
    end
  end

  private
    def item_params
      params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
    end
end
