# cronotab.rb — Crono configuration file

require 'rake'

Rails.app_class.load_tasks

Crono.perform(ClusterJob).every 30.minutes
Crono.perform(NotifierJob).every 30.minutes
Crono.perform(PlansCheckerJob).every 30.minutes
Crono.perform(WeeklyProgressJob).every 1.week, on: :sunday, at: '08:30'
Crono.perform(FeedbackReminderJob).every 1.day, at: {hour: 20, min: 10}


# in order to start crono as a daemon
# bundle exec crono start RAILS_ENV=development