# cronotab.rb — Crono configuration file

require 'rake'

Rails.app_class.load_tasks

Crono.perform(ClusterJob).every 30.minutes
Crono.perform(NotifierJob).every 30.minutes
Crono.perform(CheckPlansJob).every 30.minutes