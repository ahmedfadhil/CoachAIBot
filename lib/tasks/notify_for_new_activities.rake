desc 'create notifications'
task :create_notifications => :environment do
  require "#{Rails.root}/lib/modules/NotifierManager.rb"
  plan_id = ENV['PLAN_ID'].to_i
  plan = Plan.find(plan_id)
  notifier = NotifierManager::Notifier.new()
  puts "----result: #{notifier.notify_for_new_activities(plan)}"
end
