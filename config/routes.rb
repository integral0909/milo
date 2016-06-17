Rails.application.routes.draw do

  resources :checkings
  root 'home#index'

  devise_for :users
  post '/accounts', to: 'plaidapi#add_account'

  get "/settings" => "settings#index"

end
