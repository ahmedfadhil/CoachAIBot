require 'telegram/bot'

task :send_activity_notifications => :environment do
  token = Rails.application.secrets.bot_token
  Telegram::Bot::Client.run(token) do |bot|
    loop do
      flag = 0
      puts 'Looking for users to be Notified...'
      users = User.where('telegram_id is NULL OR telegram_id = ?', '')
      users.each do |user|
        message = "Ciao #{user.last_name}! Ti ricordo che hai le seguenti attivita' programmate "
        plans = user.plans
        plans.each do |plan|
          if plan.delivered == 1
            plan.plannings.each do |planning|
              planning.notifications.each do |notification|
                t1 = Time.now
                t2 = Time.parse(notification.time.strftime('%H:%M'))
                time_left = (t2-t1).abs.to_i
                if (!notification.sent) && (time_left < 10*60) && (Date.today == notification.date) && (notification.n_type == 'ACTIVITY_NOTIFICATION')
                  puts "User #{user.first_name} #{user.last_name} needs to be notified for activity: '#{planning.activity.name}'"
                  puts 'Notifying...'
                  notification.sent = true
                  notification.save
                  message += " ore: #{notification.time.strftime('%H:%M')} - '#{planning.activity.name}' "
                  flag = 1
                end
              end
            end
          end
        end
        if flag == 1
          bot.api.send_message(chat_id: user.telegram_id, text: message)
          puts 'Notifed!'
          flag = 0
        end

      end
      puts 'Sleeping for 2 minutes..'
      sleep 5
    end
  end
end