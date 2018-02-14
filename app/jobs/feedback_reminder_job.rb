require './lib/modules/notifier'

class FeedbackReminderJob < ActiveJob::Base
  def perform
    Notifier.new.notify_for_feedback
  end
end