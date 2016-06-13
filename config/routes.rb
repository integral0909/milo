Rails.application.routes.draw do

  root 'home#index'
  post '/accounts', to: 'application#accounts'

end
