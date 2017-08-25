module NotifierManager
  class Notifier

    def create_notifications(plan)
      puts '-----IN-----'
      if plan.delivered != 0
        false
      else
        plannings = plan.plannings
        start_date = plan.from_day
        end_date = plan.to_day

        plannings.each do |planning|
          activity_type = planning.activity.a_type

          # this lines only if activities have period
          # start_date = Date.parse(planning.from_day)
          # end_date = Date.parse(planning.to_day)
          default_time = def_time(plan)

          case activity_type
            when 'daily'
              # coach defined schedules for daily activity
              if planning.schedules.present?
                (start_date..end_date).each do |date|
                  planning.schedules.each do |schedule|
                    set(Notification.new(time: schedule.time, date: date, done: 0, n_type: 'ACTIVITY_NOTIFICATION'), planning)
                    ap 'DONE'
                    ap schedule.time
                  end
                end
                # coach did not define schedules
              else
                # set the default notifications
                (start_date..end_date).each do |date|
                  set(Notification.new(time: default_time, date: date, done: 0, n_type: 'ACTIVITY_NOTIFICATION'), planning)
                end
              end

            when 'weekly'
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

                # looping through weeks
                loop_through('week', start_date, end_date, planning, default_time)
              end

            else # 'monthly'
              if planning.schedules.present?
                planning.schedules.each do |schedule|
                  schedule.time.present? ? time = schedule.time : time = default_time
                  set(Notification.new(time: time, date: schedule.date, done: 0, n_type: 'ACTIVITY_NOTIFICATION'), planning)
                end
              else
                # looping through months
                loop_through('month', start_date, end_date, planning, default_time)
              end
          end
          unless planning.save
            false
          end
        end
        plan.delivered = 1
        if plan.save
          true
        else
          false
        end
      end
    end

    private

    def loop_through(by, start_date, end_date, planning, default_time)
      # looping through months
      from = start_date
      to = end_date
      interval = by
      start = from
      while start < to
        stop  = start.send("end_of_#{interval}")
        if stop > to
          stop = to
        end

        # create default notifications based on period and number of times to do an activity
        interval_start = Date.parse(start.inspect)
        interval_end = Date.parse(stop.inspect)
        (interval_start..interval_end).step(planning.activity.n_times) do |date|
          set(Notification.new(time: default_time, date: date, n_type: 'ACTIVITY_NOTIFICATION'), planning)
        end

        start = stop.send("beginning_of_#{interval}")
        start += 1.send(interval)
      end
    end

    def def_time(plan)
      if plan.notification_hour_user_def.present?
        hour = plan.notification_hour_user_def
      elsif plan.notification_hour_coach_def.present?
        hour = plan.notification_hour_coach_def
      else
        hour = '10:00:00'
      end
      hour
    end

    def set(notification, planning)
      notification.sent = false
      notification.planning = planning
      unless notification.save
        false
      end
      puts "\n ------ INSERITO ORARIO ------\n ATTIVITA': #{planning.activity.name} \n DATA: #{notification.date} \n ORA: #{notification.time} \n -----------------"
    end


  end
end
