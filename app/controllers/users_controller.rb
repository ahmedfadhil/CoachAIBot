class UsersController < ApplicationController
  before_action :authenticate_coach_user!
  respond_to :html, :js
  layout 'profile'

  def index
    @users = User.where(coach_user_id: current_coach_user.id)
  end

  def new
    @user = User.new
  end

  def create
    user = User.new(user_params)
    if user.save
      current_coach_user.users << user
      feature = Feature.new(physical: 0, health: 0, mental: 0, coping: 0, user_id: user.id)
      feature.save
      redirect_to users_path
    else
      flash[:error] = 'Errore durante il salvataggio dell\'utente! '
      error
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def features
    @user = User.find(params[:id])
    @features = @user.feature
  end

  def get_charts_data
    user = User.find(params[:id])
    plans = user.plans.where(delivered: 1)
    data = {:plans => []}
    i = 0
    plans.find_each do |plan|
      data[:plans].push({:name => plan.name,
                         :from_day => plan.from_day.strftime('%m/%d/%Y') ,
                         :to_day => plan.to_day.strftime('%m/%d/%Y') ,
                         :activities => []
                        })
      j = 0
      plan.plannings.find_each do |planning|
        text = 'PROGRESSO'
        notifications = planning.notifications
        feedbacks_completeness = Feedback.where('question_id = (?) AND  notification_id in (?)',
                                   planning.activity.questions.where(:q_type => 'completeness').select(:id).uniq,
                                   notifications.where(:done => 1).select(:id))
        tot = notifications.size
        done = feedbacks_completeness.where(:answer => 'Si').size
        undone = feedbacks_completeness.where(:answer => 'No').size
        done_perc = done.as_percentage_of(tot)
        undone_perc = undone.as_percentage_of(tot)
        to_do_perc = (tot-(undone+done)).as_percentage_of(tot)
        data[:plans][i][:activities].push({:name => planning.activity.name,
                                           :planning_id => planning.id,
                                           :completeness_data => {:text => text,
                                                                 :data => [["Seguita #{done_perc.to_i}%", done_perc.to_i],
                                                                           ["Saltata #{undone_perc.to_i}%", undone_perc.to_i],
                                                                           ["Da Fare #{to_do_perc.to_i}%", to_do_perc.to_i]],
                                           },
                                           :scalar_data => []
                                          })
        scalar_questions = planning.activity.questions.where(:q_type => 'scalar').select(:id).uniq
        h=0
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
    render json: data, status: :ok
  end

  # active users
  def active
    @users = User.all.limit 1
    render 'users/index'
  end

  #suspended users
  def suspended
    @users = User.all.limit 10
    render 'users/index'
  end

  #archived users
  def archived
    @users = User.all.limit 4
    render 'users/index'
  end

  def plans
    @user = User.find(params[:id])
    @plans = @user.plans
  end

  def active_plans
    @user = User.find(params[:id])
    @plans = @user.plans.where(:delivered => 1)
  end

  def suspended_plans
    @user = User.find(params[:id])
    @plans = @user.plans.where(:delivered => 2)
  end

  def interrupted_plans
    @user = User.find(params[:id])
    @plans = @user.plans.where(:delivered => 3)
  end

  def finished_plans
    @user = User.find(params[:id])
    @plans = @user.plans.where(:delivered => 4)
  end

  def get_plans_pdf
    user = User.find(params[:id])
    @plans = user.plans

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{user.first_name}-Plans",
               template: 'users/user_plans',
               show_as_html: params.key?('debug'),
               disable_smart_shrinking: true
               #dpi: '400'
      end
    end
  end


  private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :cellphone)
    end

  def error
    render 'error/error.html.erb'
  end

  def percent_of(n)
    self.to_f / n.to_f * 100.0
  end

end
