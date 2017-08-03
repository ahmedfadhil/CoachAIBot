class UsersController < ApplicationController
  before_action :authenticate_coach_user!
  respond_to :html, :js
  layout 'profile'

  def index
    @users = Patient.where(coach_user_id: current_coach_user.id)
  end

  def new
    @user = Patient.new
  end

  def create
    user = Patient.new(user_params)
    if user.save
      current_coach_user.users << user
      redirect_to users_path
    else
      flash[:error] = 'Errore durante il salvataggio dell\'utente! '
      error
    end
  end

  def show
    @user = Patient.find(params[:id])
    @plans = @user.plans
  end


  # active users
  def active
    @users = Patient.all.limit 1
    render 'users/index'
  end

  #suspended users
  def suspended
    @users = Patient.all.limit 10
    render 'users/index'
  end

  #archived users
  def archived
    @users = Patient.all.limit 4
    render 'users/index'
  end


  private

    def user_params
      params.require(:patient).permit(:first_name, :last_name, :email, :cellphone)
    end

  def error
    render 'error/error.html.erb'
  end

end
