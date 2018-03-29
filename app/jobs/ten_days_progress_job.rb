require './lib/modules/notifier'

class TenDaysProgressJob < ActiveJob::Base
  def perform
    users = User.joins(:plans).where(:plans => {:delivered => 1} ).uniq
    users.each do |user|
      Notifier.new.notify_user_progress user
    end
  end
end