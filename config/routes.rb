Rails.application.routes.draw do
  resources :activities

  resources :plans do
    collection do
      get 'new/:u_id', to: 'plans#new', as: 'new'
    end
  end

  resources :users do
    collection do
      get 'active'
      get 'archived'
      get 'suspended'
    end
  end

  resources :plannings do
    collection do
      post 'new/:p_id/:u_id', to: 'plannings#new', as: 'new'
      post 'dissociate/:a_id/:p_id/:u_id', to: 'activities#dissociate', as: 'dissociate'
    end
  end

  resources :schedules

  resources :questions do
    collection do
      get 'new/a_id', to: 'questions#new', as: 'new'
    end
  end


  get 'profile/index'
  get 'static_pages/help'
  get 'static_pages/about'

  devise_for :coach_users
  get 'home/index'
  root 'home#index'

  # Telegram webhook
  post '/webhooks/telegram_vbc43edbf1614a075954dvd4bfab34l1' => 'webhooks#callback'


end
