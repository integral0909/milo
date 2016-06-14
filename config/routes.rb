Rails.application.routes.draw do

  root 'home#index'

  devise_for :users
  post '/accounts', to: 'plaidapi#add_account'

end
