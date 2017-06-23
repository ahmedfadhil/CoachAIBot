Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/webhooks/telegram_vbc43edbf1614a075954dvd4bfab34l1' => 'webhooks#callback'

  post '/webhooks/update_from_chatscript' => 'webhooks#update_user_state'

end
