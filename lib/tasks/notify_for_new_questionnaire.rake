desc 'notifies a new questionnaire to the user/patient'
task :notify_for_new_questionnaire => :environment do
  require "#{Rails.root}/lib/modules/notifier.rb"
  user_id = ENV['USER_ID'].to_i
  user = User.find(user_id)
  notifier = Notifier.new
  notifier.notify_new_questionnaire(user)
end
