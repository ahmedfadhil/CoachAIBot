Rails.application.routes.draw do
  get 'errors/not_found'
  
  get 'errors/internal_server_error'
  
  # crono jobs route
  mount Crono::Web, at: '/crono'
  
  resources :communications do
    collection do
      get 'lasts/:id', to: 'communications#lasts', as: 'lasts'
      get 'all/:id', to: 'communications#all', as: 'all'
    end
  end
  
  resources :activities do
    collection do
      get 'diets', to: 'activities#diets', as: 'diets'
      get 'physicals', to: 'activities#physicals', as: 'physicals'
      get 'mentals', to: 'activities#mentals', as: 'mentals'
      get 'medicinals', to: 'activities#medicinals', as: 'medicinals'
      get 'others', to: 'activities#others', as: 'others'
      get 'saveAllData', to: 'activities#saveAllData', as: 'saveAllData'
      get 'saveUserData/:id', to: 'activities#saveUserData', as: 'saveUserData'
    end
  end
  
  resources :chats do
    collection do
      get 'chat/:id', to: 'chats#chat', as: 'chat'
      get 'chats/:id', to: 'chats#chats', as: 'chats'
    end
  end
  
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
      get ':id/get_feedbacks_to_do_pdf.pdf', to: 'users#get_feedbacks_to_do_pdf', as: 'get_feedbacks_to_do_pdf'
      get ':id/get_charts_data', to: 'users#get_charts_data', as: 'get_charts_data'
      get 'get_scores', to: 'users#get_scores', as: 'get_scores'
      get 'get_images', to: 'users#get_images', as: 'get_images'
      get 'archive/:id', to: 'users#archive', as: 'archive'
      get 'restore/:id', to: 'users#restore', as: 'restore'
    end
  end
  
  resources :plannings do
    collection do
      post 'new/:p_id/:u_id', to: 'plannings#new', as: 'new'
      post 'assign/:p_id/:u_id/a_id', to: 'plannings#assign', as: 'assign'
      post 'dissociate/:a_id/:p_id/:u_id', to: 'activities#dissociate', as: 'dissociate'
      post 'destroy_all_schedules/:p_id', to: 'plannings#destroy_all_schedules', as: 'destroy_all_schedules'
    end
  end
  
  resources :schedules
  
  resources :questions do
    collection do
      get 'new/planning_id', to: 'questions#new', as: 'new'
    end
  end
  
  # pdf
  get '/pdf/user_plans_pdf', to: 'pdf#user_plans_pdf', as: 'user_plans_pdf'
  
  get 'profile/index'
  get 'static_pages/help'
  get 'static_pages/about'
  
  devise_for :coach_users #, :controllers => {sessions: 'sessions'}
  get 'home/index'
  root 'home#index'

  resources :coach_users do
    collection do
      get 'coach_users/:id', to: 'coach_users#show', as: 'show'
    end
    end
  
  # Webhooks
  post '/webhooks/telegram_vbc43edbf1614a075954dvd4bfab34l1' => 'webhooks#callback'
  
  # Wearable devices
  # Actions reserved for the coach:
  get 'wearables', to: 'wearables#index', as: 'wearables'
  get 'wearables/:id', to: 'wearables#show', as: 'wearables_show'
  post 'wearables/:id/invite', to: 'wearables#invite', as: 'wearables_invite'
  # Actions reserved for the user
  # starts fitbit oauth2 procedure
  get 'wearables/fitbit/connect/:token', to: 'wearables#connect', as: 'wearables_fitbit_connect'
  # oauth2 callback
  get 'users/auth/fitbit/callback', to: 'wearables#oauth2_callback'
  
  
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all


end
