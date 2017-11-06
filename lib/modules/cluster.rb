require 'bot/general_actions'

# Congregate patients, that is, clusters patients into 3 main clusters <GREEN>, <YELLOW>, <RED>
class Cluster
  YELLOW_THRESHOLD, RED_THRESHOLD = 0.05, 0.2
  DAILY, WEEKLY, MONTHLY, NO_ANSWER = '0', '1', '2', 'No'
  GREEN, YELLOW, RED = 0, 1, 2

  def init
    puts 'Ready to cluster!'
  end

  def group
    users = User.joins(:plans).where(:plans => {:delivered => 1} )
    users.find_each do |user|
      plans = user.plans.where(:delivered => 1)
      therms = get_therms(plans)
      mark(user, therms[:to_do_activities], therms[:undone_activities], therms[:undone_feedback_days])
    end
  end

  def get_therms(delivered_plans)
    to_do = 0
    undone_activities = 0

    delivered_plans.find_each do |plan|
      periods = periods(plan)
      plan.plannings.find_each do |planning|
        to_do += count_activities(planning.activity, periods)
        undone_activities += count_undone_activities(planning)
      end
    end

    {
        :to_do_activities => to_do,
        :undone_activities => undone_activities,
        :undone_feedback_days => undone_feedback_days(delivered_plans)
    }
  end

  def periods(plan)
    {:days => TimeDifference.between(plan.from_day, plan.to_day).in_days,
     :weeks => TimeDifference.between(plan.from_day, plan.to_day).in_weeks,
     :months => TimeDifference.between(plan.from_day, plan.to_day).in_months}
  end

  def count_activities(activity, plan_periods)
    n_per_period = activity.n_times
    case activity.a_type
      when DAILY
        n_per_period * plan_periods[:days]
      when WEEKLY
        n_per_period * plan_periods[:weeks]
      else # when MONTHLY
        n_per_period * plan_periods[:months]
    end
  end

  def count_undone_activities(planning)
    undone = 0
    question_id = planning.activity.questions.where(:q_type => 'completeness').first.id
    planning.notifications.where('date < ?', Date.today).find_each do |notification|
      undone += notification.feedbacks.where(:question_id => question_id, :answer => NO_ANSWER).count
    end
    undone
  end

  def undone_feedback_days(delivered_plans)
    undone = 0
    if delivered_plans.maximum('to_day') < Date.today
      upper_extremity_date = delivered_plans.maximum('to_day')
    else
      upper_extremity_date = Date.today
    end

    (delivered_plans.minimum('from_day')..upper_extremity_date).each do |date|
      flag = false
      delivered_plans.each do |plan|
        unless Feedback.joins(notification: :planning).where(:plannings => {:plan_id => plan.id}, :notifications => {:date => date}).exists?
          flag = true
        end
      end
      undone += 1 if flag == true
    end

    undone
  end


  # performs Cluster's main check
  def mark(user, to_do_activities, undone_activities, undone_feedback_days)
    if (undone_activities <= YELLOW_THRESHOLD*to_do_activities) && (undone_feedback_days <= 3 )
      update(user, GREEN)
    elsif (undone_activities <= RED_THRESHOLD*to_do_activities) && (undone_feedback_days <= 6 )
      update(user, YELLOW)
    else
      update(user, RED)
    end
  end

  def update(user, cluster)
    user.cluster = cluster
    user.save
  end
end