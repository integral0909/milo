Rails.application.routes.draw do

  root 'home#index'
  post '/accounts', to: 'plaidapi#add_account'

end
