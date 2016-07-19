Rails.application.routes.draw do

  devise_for :users
  resources :users, :only => [:show] do
    resources :transactions, only: [:index, :show, :edit, :update]
    resources :accounts, only: [:index]
  end

  # Root, User Logged In
  authenticated :user do
    root 'home#index', as: :authenticated_root
  end
  # Root, User Logged Out
  root 'pages#show', page: 'home'

  resources :checkings

  # Pages for Marketing Site
  get '/*page' => 'pages#show'

  post '/users/:id/add_account', to: 'plaidapi#add_account'
  patch '/users/:id/update_accounts', to: 'plaidapi#update_accounts'

  get "/settings" => "settings#index"

end
