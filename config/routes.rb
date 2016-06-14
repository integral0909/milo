Rails.application.routes.draw do

  devise_for :users
  root 'home#index'
  post '/accounts', to: 'plaidapi#add_account'

end
