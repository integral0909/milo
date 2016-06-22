Rails.application.routes.draw do

  resources :checkings
  root 'home#index'

  devise_for :users
  resources :users, :only => [:show] do
    resources :transactions, only: [:index, :show, :edit, :update]
    resources :accounts, only: [:index]
  end

  post '/users/:id/add_account', to: 'plaidapi#add_account'
  patch '/users/:id/update_accounts', to: 'plaidapi#update_accounts'

  get "/settings" => "settings#index"

end
