require 'telegram/bot'

# creates all the notifications for the user, that are reminders
class Notifier

  def create_notifications(plan)
    plannings = plan.plannings
    start_date = plan.from_day
    end_date = plan.to_day

    plannings.each do |planning|

      # if activities have period we could just do:
      # start_date = Date.parse(planning.from_day)
      # end_date = Date.parse(planning.to_day)

      default_time = def_time(plan)
      case planning.activity.a_type
        when '0'
          create_notifications_daily(planning, start_date, end_date, default_time)
        when '1'
          create_notifictions_weekly(planning, start_date, end_date, default_time)
        else
          create_notifications_monthly(planning, start_date, end_date, default_time)
      end
    end

  end

  def create_notifications_daily(planning, start_date, end_date, default_time)
    # coach defined schedules for daily activity
    if planning.schedules.present?
      (start_date..end_date).each do |date|
        planning.schedules.each do |schedule|
          set(Notification.new(time: schedule.time, date: date, done: 0, n_type: 'ACTIVITY_NOTIFICATION'), planning)
        end
      end

      # coach did not define schedules
    else
      # set the default notifications
      (start_date..end_date).each do |date|
        set(Notification.new(time: default_time, date: date, done: 0, n_type: 'ACTIVITY_NOTIFICATION'), planning)
      end
    end
    planning.save!
  end

  def create_notifictions_weekly(planning, start_date, end_date, default_time)
    if planning.schedules.present?
      (start_date..end_date).each do |date|
        planning.schedules.each do |schedule|
          if date.wday == schedule.day + 1
            schedule.time.present? ? time = schedule.time : time = default_time
            set(Notification.new(time: time, date: date, done: 0, n_type: 'ACTIVITY_NOTIFICATION'), planning)
          end
        end
      end
    else
      loop_through('week', start_date, end_date, planning, default_time)
    end
    planning.save
  end

  def create_notifications_monthly(planning, start_date, end_date, default_time)
    if planning.schedules.present?
      planning.schedules.each do |schedule|
        schedule.time.present? ? time = schedule.time : time = default_time
        set(Notification.new(time: time, date: schedule.date, done: 0, n_type: 'ACTIVITY_NOTIFICATION'), planning)
      end
    else
      loop_through('month', start_date, end_date, planning, default_time)
    end
    planning.save
  end

  def notify_for_new_activities(plan)
    token = Rails.application.secrets.bot_token
    api = ::Telegram::Bot::Api.new(token)
    user = plan.user
    message = "Nuove Attivita' sono state definite per te #{user.first_name}. Vai nella sezione ATTIVITA' per avere ulteriori dettagli."
    api.call('sendMessage', chat_id: user.telegram_id, text: message)
  end

  private

  # loops through a period with a step=by and
  # create default notifications based on period and number of times to do an activity
  def loop_through(by, start_date, end_date, planning, default_time)
    from = start_date
    to = end_date
    interval = by
    start = from
    while start < to
      stop  = start.send("end_of_#{interval}")
      if stop > to
        stop = to
      end

      interval_start = Date.parse(start.inspect)
      interval_end = Date.parse(stop.inspect)
      step = ((interval_end - interval_start).to_i / planning.activity.n_times) + 1
      (interval_start..interval_end).step(step) do |date|
        set(Notification.new(time: default_time, done: 0, date: date, n_type: 'ACTIVITY_NOTIFICATION'), planning)
      end

      start = stop.send("beginning_of_#{interval}")
      start += 1.send(interval)
    end
  end

  def def_time(plan)
    if plan.notification_hour_user_def.present?
      plan.notification_hour_user_def
    elsif plan.notification_hour_coach_def.present?
      plan.notification_hour_coach_def
    else
      '10:00:00'
    end
  end

  def set(notification, planning)
    notification.sent = false
    notification.planning = planning
    notification.save!
    puts "creata notifica per #{planning.activity.name} data #{notification.date} ora #{notification.time}"
  end

end