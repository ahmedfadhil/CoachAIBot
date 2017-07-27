require 'telegram/bot'
task :notify => :environment do
  token = Rails.application.secrets.bot_token
  Telegram::Bot::Client.run(token) do |bot|
    bot.api.send_message(chat_id: 104119130, text: 'Hello, world')
  end
end