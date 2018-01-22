desc 'notifies when a plan was deleted'
task :notify_deleted_plan => :environment do
  require "#{Rails.root}/lib/modules/notifier.rb"
  plan_name = ENV['PLAN_NAME']
  user = User.find(ENV['USER_ID'].to_i)
  notifier = Notifier.new
  notifier.notify_deleted_plan(plan_name, user)
end
