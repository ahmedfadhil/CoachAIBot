require './lib/modules/chart_data_binder'

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
    if user.valid?
      user.save
      current_coach_user.users << user
      features = generate_features user
      if features.nil?
        flash[:notice] = "C'e' stato un problema interno e l'utente non e' stato inserito, riprova piu' tardi!"
      else
        flash[:notice] = 'Utente inserito con successo!'
      end
    else
      flash[:notice] = user.errors.messages
    end
    ap flash
    redirect_to users_path
  end

  def show
    @user = User.find(params[:id])
  end

  def features
    @features = User.find(params[:id]).feature
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

  def get_charts_data
    user = User.find(params[:id])
    data = ChartDataBinder.new.get_overview_data(user)
    render json: data, status: :ok
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
               dpi: '250',
               # orientation: 'Landscape',
               viewport: '1280x1024',
               footer: { right: '[page] of [topage]' }
      end
    end
  end

  def get_feedbacks_to_do_pdf
    @plans = Plan.joins(plannings: :notifications).where('notifications.date<=? AND notifications.done=? AND plans.delivered=? AND plans.user_id=?', Date.today, 0, 1, params[:id]).uniq
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{@plans[0].user.first_name}-Plans",
               template: 'users/user_feedbacks',
               show_as_html: params.key?('debug'),
               dpi: '250',
               # orientation: 'Landscape',
               viewport: '1280x1024',
               footer: { right: '[page] of [topage]' }
      end
    end
  end

  def get_scores
    data = ChartDataBinder.new.get_scores(current_coach_user)
    render json: data, status: :ok
  end


  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :cellphone)
  end

  def generate_features(user)
    Feature.create(physical: 0, health: 0, mental: 0, coping: 0, user_id: user.id)
  end

end
