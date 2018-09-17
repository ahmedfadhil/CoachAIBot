# cronotab.rb — Crono configuration file

require 'rake'

Rails.app_class.load_tasks

Crono.perform(ClusterJob).every 30.minutes
Crono.perform(PlansCheckerJob).every 30.minutes
Crono.perform(WeeklyProgressJob).every 1.week, on: :sunday, at: '08:30'
Crono.perform(TenDaysProgressJob).every 10.days

# Notify Today's Activities --> in the morning
Crono.perform(NotifierJob).every 1.day, at: {hour: 8, min: 10}
Crono.perform(NotifierJob).every 1.day, at: {hour: 9, min: 10}
Crono.perform(NotifierJob).every 1.day, at: {hour: 10, min: 10}
Crono.perform(NotifierJob).every 1.day, at: {hour: 11, min: 10}
Crono.perform(NotifierJob).every 1.day, at: {hour: 15, min: 10}
Crono.perform(NotifierJob).every 1.day, at: {hour: 18, min: 20}

# Notify Reminder for Feedback --> in the evening
Crono.perform(FeedbackReminderJob).every 1.day, at: {hour: 20, min: 10}

class FitbitPullData
  def perform
    Rake::Task['fitbit:pull_data'].invoke
  end
end

Crono.perform(FitbitPullData).every 2.hour

# in order to start crono as a daemon
# bundle exec crono start RAILS_ENV=development
