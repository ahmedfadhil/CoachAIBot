require './lib/modules/communicator'

class PlansCheckerJob < ActiveJob::Base
  def perform
    Communicator.new.check_plans
  end
end