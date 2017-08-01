task :delete_telegram_id => :environment do
  u = User.last
  u.telegram_id = '123'
  u.save
end