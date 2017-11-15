desc 'clusters the patients using a python script'
task :python_clustering => :environment do
  require "#{Rails.root}/lib/modules/notifier.rb"
  plan_id = ENV['PLAN_ID'].to_i
  plan = Plan.find(plan_id)
  notifier = Notifier.new
  notifier.notify_for_new_activities(plan)
end
