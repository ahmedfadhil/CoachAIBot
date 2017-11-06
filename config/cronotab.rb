# cronotab.rb — Crono configuration file

require 'rake'

Rails.app_class.load_tasks

Crono.perform(ClusterJob).every 2.minutes
Crono.perform(NotifierJob).every 2.minutes
Crono.perform(PlanCheckerJob).every 2.minutes