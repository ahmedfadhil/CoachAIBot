require './lib/modules/communicator'

class CheckPlanJobs < ActiveJob::Base
  def perform
    Communicator.new.check_plans
  end
end