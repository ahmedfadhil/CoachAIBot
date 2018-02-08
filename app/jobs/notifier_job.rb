require './lib/modules/notifier'

class NotifierJob < ActiveJob::Base
  def perform
    Notifier.new.check_and_notify
  end
end