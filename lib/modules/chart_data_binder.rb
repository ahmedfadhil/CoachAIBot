# collects data needed to create charts for user
class ChartDataBinder
  DIET, PHYSICAL, MENTAL = '0', '1', '2'
  YES_ANSWER, NO_ANSWER = 'Si', 'No'
  ARCHIVED = 'ARCHIVED'
  
  def init
  end
  
  def get_scores(coach)
    users = coach.users.where('state <> ?', ARCHIVED)
    data = {:users => []}
    data.tap do
      users.find_each do |user|
        data[:users].push({
                              :id => user.id,
                              :diet_score => score(user, DIET),
                              :physical_score => score(user, PHYSICAL),
                              :mental_score => score(user, MENTAL),
                          })
      end
    end
  end
  
  def score(user, category)
    plannings = plannings_of(user, category)
    total = Notification.where('notifications.planning_id in (?)', plannings.map(&:id)).uniq.count
    positive = Notification.joins(:feedbacks).where('notifications.planning_id in (?) AND feedbacks.answer = ?', plannings.map(&:id), YES_ANSWER).uniq.count
    total > 0 ? positive.as_percentage_of(total).to_i : 0
  end
  
  def plannings_of(user, type)
    Planning.joins(:plan, :activity).where(:plans => {:delivered => 1, :user_id => user.id}, :activities => {:category => type})
  end
  
  def get_images(coach)
    users = coach.users.where('state <> ?', ARCHIVED)
    data = {:users => []}
    data.tap do
      users.find_each do |user|
        data[:users].push({
                              :id => user.id,
                              :profile_img => profile_image_path(user)
                          })
      end
    end
  end
  
  def profile_image_path(user)
    if user.telegram_id.nil?
      default_image
    else
      begin
        solver = ImageSolver.new
        solver.solve(user.telegram_id)
      rescue Exception
        default_image
      end
    end
  end
  
  def default_image
    'https://i.imgur.com/hur32sb.png'
    # 'https://i.imgur.com/Sf5Waux.png'
  end
  
  def get_overview_data(user)
    plans = user.plans.where('delivered = ? OR delivered = ?', 1, 4)
    data = {:plans => []}
    i = 0
    plans.find_each do |plan|
      data[:plans].push({:name => plan.name,
                         :from_day => plan.from_day.strftime('%m/%d/%Y'),
                         :to_day => plan.to_day.strftime('%m/%d/%Y'),
                         :activities => []
                        })
      j = 0
      plan.plannings.find_each do |planning|
        text = 'PROGRESSO'
        notifications = planning.notifications
        feedbacks_completeness = Feedback.where('question_id = (?) AND  notification_id in (?)',
                                                planning.questions.where(:q_type => 'completeness').select(:id).uniq,
                                                notifications.where(:done => 1).select(:id))
        tot = notifications.size
        done = feedbacks_completeness.where(:answer => 'Si').size
        undone = feedbacks_completeness.where(:answer => 'No').size
        done_perc = done.as_percentage_of(tot)
        undone_perc = undone.as_percentage_of(tot)
        to_do_perc = (tot - (undone + done)).as_percentage_of(tot)
        data[:plans][i][:activities].push({:name => planning.activity.name,
                                           :planning_id => planning.id,
                                           :completeness_data => {:text => text,
                                                                  :data => [["Seguita #{done_perc.to_i}%", done_perc.to_i],
                                                                            ["Saltata #{undone_perc.to_i}%", undone_perc.to_i],
                                                                            ["Da Fare #{to_do_perc.to_i}%", to_do_perc.to_i]],
                                           },
                                           :open_data => [],
                                           :scalar_data => [],
                                           :yes_no_data => []
                                          })
        
        yes_no_questions = planning.questions.where(:q_type => 'yes_no').select(:id).uniq
        yes_no_questions.each do |q|
          feedbacks_yes_no = Feedback.where('question_id = (?) AND  notification_id in (?)',
                                            q.id,
                                            notifications.where(:done => 1).select(:id))
          tot = feedbacks_yes_no.size
          yes = Feedback.where('question_id = (?) AND  notification_id in (?) and answer = ?',
                               q.id,
                               notifications.where(:done => 1).select(:id), 'si').size
          no = Feedback.where('question_id = (?) AND  notification_id in (?) and answer = ?',
                              q.id,
                              notifications.where(:done => 1).select(:id), 'no').size
          unless tot == 0
            yes_perc = yes.as_percentage_of(tot)
            no_perc = no.as_percentage_of(tot)
            data[:plans][i][:activities][j][:yes_no_data].push({:text => Question.find(q.id).text,
                                                                :data => [["Si #{yes_perc.to_i}%", yes_perc.to_i],
                                                                          ["No #{no_perc.to_i}%", no_perc.to_i]]
                                                               })
          end
        
        end
        
        
        open_questions = planning.questions.where(:q_type => 'open').select(:id).uniq
        h = 0
        open_questions.each do |q|
          feedbacks_open = Feedback.where('question_id = (?) AND  notification_id in (?)',
                                          q.id,
                                          notifications.where(:done => 1).select(:id))
          data[:plans][i][:activities][j][:open_data].push({:text => Question.find(q.id).text,
                                                            :data => []
                                                           })
          answers = q.answers.map(&:text)
          tot = feedbacks_open.size
          answers.each do |a|
            percentage_a = feedbacks_open.where(answer: a).count.as_percentage_of(tot)
            data[:plans][i][:activities][j][:open_data][h][:data].push({:name => a, :data => [percentage_a.to_i]})
          end
          h = h + 1
        end
        
        
        scalar_questions = planning.questions.where(:q_type => 'scalar').select(:id).uniq
        h = 0
        scalar_questions.each do |q|
          feedbacks_scalars = Feedback.where('question_id = (?) AND  notification_id in (?)',
                                             q.id,
                                             notifications.where(:done => 1).select(:id))
          
          data[:plans][i][:activities][j][:scalar_data].push({:text => Question.find(q.id).text,
                                                              :data => []
                                                             })
          
          feedbacks_scalars.find_each do |f|
            t = f.notification.date.to_time
            t += t.utc_offset
            t = t.to_i * 1000
            data[:plans][i][:activities][j][:scalar_data][h][:data].push([t, f.answer.to_f])
          end
          
          
          h = h + 1
        end
        j = j + 1
      end
      i = i + 1
    end
    ap data
    data
  end
end