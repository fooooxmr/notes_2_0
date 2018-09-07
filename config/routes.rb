Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  root 'notes#index'

  resources :notes

  resources :export, only: :create, defaults: { format: :csv }
end
