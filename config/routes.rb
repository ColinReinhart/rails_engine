Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :merchants, only: %i[index show] do
        resources :items, only: %i[index], to: 'merchant_items#index'
      end
      resources :items, only: [:index, :show, :create, :update, :destroy] do
        resources :merchant, only: [:index], to: 'item_merchants#index'
      end
      end
    end
  end
