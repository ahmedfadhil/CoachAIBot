Rails.application.routes.draw do
  resources :activities

  resources :plans do
    collection do
      post 'new/:u_id', to: 'plans#new', as: 'new'
      post 'deliver/:p_id', to: 'plans#deliver', as: 'deliver'
      post 'suspend/:p_id', to: 'plans#suspend', as: 'suspend'
      post 'stop/:p_id', to: 'plans#stop', as: 'stop'
    end
  end

  resources :users do
    collection do
      get 'plans/:id', to: 'users#plans', as: 'plans'
      get 'features/:id', to: 'users#features', as: 'features'
      get 'active_plans/:id', to: 'users#active_plans', as: 'active_plans'
      get 'suspended_plans/:id', to: 'users#suspended_plans', as: 'suspended_plans'
      get 'interrupted_plans/:id', to: 'users#interrupted_plans', as: 'interrupted_plans'
      get 'finished_plans/:id', to: 'users#finished_plans', as: 'finished_plans'
      get 'active'
      get 'archived'
      get 'suspended'
      get ':id/get_plans.pdf', to: 'users#get_plans_pdf', as: 'get_plans_pdf'
      get ':id/get_charts_data', to: 'users#get_charts_data', as: 'get_charts_data'
    end

		member do
			get 'wearables'
			post 'fitbit_invite'
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

  # pdf
  get '/pdf/user_plans_pdf', to: 'pdf#user_plans_pdf', as: 'user_plans_pdf'

  get 'profile/index'
  get 'static_pages/help'
  get 'static_pages/about'

  devise_for :coach_users
  get 'home/index'
  root 'home#index'

  # Webhooks
  post '/webhooks/telegram_vbc43edbf1614a075954dvd4bfab34l1' => 'webhooks#callback'
  post '/webhooks/chatscript_vbc43edbf1614a075954dvd4bfab34l1/upload_health_features' => 'webhooks#upload_health_features'

	# start fitbit oauth2 procedure
	get 'wearables/fitbit/connect/:token', to: 'wearables#connect', as: 'wearables_fitbit_connect'
	get 'users/auth/fitbit/callback', to: 'wearables#oauth2_callback'
	# webhook callback
	get 'fitbit/webhook', to: 'wearables#webhook'
end
