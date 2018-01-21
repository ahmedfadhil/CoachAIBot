# cronotab.rb — Crono configuration file

require 'rake'

Rails.app_class.load_tasks

Crono.perform(ClusterJob).every 5.minutes
Crono.perform(NotifierJob).every 5.minutes
Crono.perform(PlansCheckerJob).every 5.minutes
Crono.perform(WeeklyProgressJob).every 1.week, on: :sunday, at: '08:30'


# in order to start crono as a daemon
# bundle exec crono start RAILS_ENV=development