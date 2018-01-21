require './lib/modules/notifier'

class WeeklyProgressJob < ActiveJob::Base
  def perform
    users = User.joins(:plans).where(:plans => {:delivered => 1} ).uniq
    users.each do |user|
      Notifier.new.notify_weekly_progress user
    end
  end
end