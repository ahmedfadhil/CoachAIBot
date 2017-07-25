Rails.application.routes.draw do
  resources :activities do
    collection do
      post 'new_assign/:p_id/:u_id', to: 'activities#new_assign', as: 'new_assign'
      post 'assign/:a_id/:p_id/:u_id', to: 'activities#assign', as: 'assign'
      post 'dissociate/:a_id/:p_id/:u_id', to: 'activities#dissociate', as: 'dissociate'
    end
  end

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

  resources :a_schedule

  get 'profile/index'
  get 'static_pages/help'
  get 'static_pages/about'

  devise_for :coach_users
  get 'home/index'
  root 'home#index'

  # Telegram webhook
  post '/webhooks/telegram_vbc43edbf1614a075954dvd4bfab34l1' => 'webhooks#callback'

=begin

  resources :activities_plan do
    member do
      get 'assign/:a_id/:p_id/', to: 'activities_plan#assign', as: 'assign'
    end
  end


  get 'users/active', to: 'users#active', as: 'active'
  get 'users/archived', to: 'users#archived', as: 'archived'
  get 'users/suspended', to: 'users#suspended', as: 'suspended'


  post 'users/create'

  get 'users/index'
  get 'users/new_assign'
  get 'users/:id', to: 'users#show', as: 'user'
=end


end
