Rails.application.routes.draw do

  get 'static_pages/help'

  get 'static_pages/about'

  devise_for :coach_users
  get 'home/index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/webhooks/telegram_vbc43edbf1614a075954dvd4bfab34l1' => 'webhooks#callback'

  root 'home#index'

end
