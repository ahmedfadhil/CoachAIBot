require './lib/modules/plan_checker'

class PlanCheckerJob < ActiveJob::Base
  def perform
    Communicator.new.check_plans
  end
end