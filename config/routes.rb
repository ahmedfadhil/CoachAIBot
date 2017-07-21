Rails.application.routes.draw do
  resources :activities

  resources :plans

  resources :activities_users do
    member do
      get 'assign/:id/:plan_id/', to: 'activities_users#assign', as: 'assign'
    end

  end


  get 'users/active'
  get 'users/archived'
  get 'users/suspended'

  post 'users/create'

  get 'users/index'
  get 'users/new'
  get 'users/:id', to: 'users#show', as: 'user'

  get 'profile/index'

  get 'static_pages/help'
  get 'static_pages/about'

  devise_for :coach_users
  get 'home/index'

  # Telegram webhook
  post '/webhooks/telegram_vbc43edbf1614a075954dvd4bfab34l1' => 'webhooks#callback'

  root 'home#index'

end
