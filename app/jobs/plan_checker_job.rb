require './lib/modules/plan_checker'

class PlanCheckerJob < ActiveJob::Base
  def perform
    PlanChecker.new.check_and_notify
  end
end