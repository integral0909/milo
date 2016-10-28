Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  # Devise
  devise_for :users, :controllers => { registrations: 'registrations', sessions: 'sessions', passwords: 'passwords' }
    resources :users, :only => [:show] do
    resources :transactions, only: [:index, :show, :edit, :update]
    resources :accounts, only: [:index]
  end

  devise_scope :user do
    # User Settings
    get 'settings', to: 'registrations#edit', as: :settings
    get 'settings/accounts', to: 'registrations#accounts', as: :settings_accounts
    get 'settings/security', to: 'registrations#security', as: :settings_security
    # User Sign Up
    get 'signup/phone', to: 'registrations#phone', as: :signup_phone
    get 'signup/phone_confirm', to: 'registrations#phone_confirm', as: :signup_phone_confirm
    get 'signup/on_demand', to: 'registrations#on_demand', as: :signup_on_demand
  end

  # Root, User Logged In
  authenticated :user do
    root 'home#index', as: :authenticated_root
  end
  # Root, User Logged Out
  root 'pages#show', page: 'home'

  # Mobile Phone Verification
  post 'verifications' => 'verifications#create'
  patch 'verifications' => 'verifications#verify'

  # Remove Bank Accounts
  get 'accounts/remove', to: 'accounts#remove', as: :accounts_remove

  resources :checkings
  resources :contacts, only: [:new, :create]
  resources :goals, only: [:create, :destroy]

  # Pages for Marketing Site
  get '/*page' => 'pages#show'

  # Plaid Link to Connect Bank Account
  post '/users/:id/add_account', to: 'plaidapi#add_account'
  patch '/users/:id/update_accounts', to: 'plaidapi#update_accounts'

end
