require 'bot/general'
require 'csv'

# Congregate patients, that is, clusters patients into 3 main clusters <GREEN>, <YELLOW>, <RED>
class Cluster
  YELLOW_THRESHOLD, RED_THRESHOLD = 0.05, 0.2
  DAILY, WEEKLY, MONTHLY, NO_ANSWER = '0', '1', '2', 'No'
  GREEN, YELLOW, RED = 0, 1, 2
  PROCESS_EXITED = 1
  
  def init
  end
  
  def group
    users = User.joins(:plans).where(:plans => {:delivered => 1}).uniq
    users.each do |user|
      plans = user.plans.where(:delivered => 1)
      therms = get_therms(plans)
      mark(user, therms[:to_do_activities], therms[:undone_activities], therms[:undone_feedback_days])
    end
  end
  
  def group_py
    pid = Process.spawn('python3 scripts/Adherence.py') # launch another process in order to call python script from shell
    wait_until_process_exit(pid) # we can do it without disturbing tha rails server because it will be done during the task processing
    process_result
  end
  
  private
  
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
    question_id = planning.questions.where(:q_type => 'completeness').first.id
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
    if (undone_activities <= YELLOW_THRESHOLD * to_do_activities) && (undone_feedback_days <= 3)
      update(user, GREEN)
    elsif (undone_activities <= RED_THRESHOLD * to_do_activities) && (undone_feedback_days <= 6) && (undone_feedback_days > 3)
      update(user, YELLOW)
    else
      if user.cluster != 2 #we use a string because
        communicator = Communicator.new
        communicator.communicate_user_critical(user)
      end
      update(user, RED)
    end
  end
  
  def update(user, cluster)
    if user.cluster != cluster
      user.cluster = cluster
      user.save
    end
  end
  
  def wait_until_process_exit(pid)
    checker = Process.waitpid(pid, Process::WNOHANG)
    while checker.nil? # => nil
      checker = Process.waitpid(pid, Process::WNOHANG)
    end
    ap "PROCESS #{checker} FINISHED" if checker == pid
  end
  
  def process_result
    path = "#{Rails.root}/csvs/result.csv"
    file = File.open(path, 'r')
    rows = CSV.parse(file, headers: true)
    rows.each do |row|
      id = row[1]
      ap "READING USER_ID=#{id}"
      unless id.nil?
        prediction = row[6]
        save_py_prediction(id, prediction)
      end
    end
  end
  
  def save_py_prediction(id, prediction)
    begin
      user = User.find(id)
      user.py_cluster = prediction
      user.save!
    rescue Exception => e
      ap "rescued from:"
      ap e.message
      ap e.backtrace.inspect
    end
  end
end