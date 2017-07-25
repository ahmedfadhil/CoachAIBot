class UsersController < ApplicationController
  before_action :authenticate_coach_user!
  respond_to :html, :js
  layout 'profile'

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if !@user.save
      render 'error/error.html.erb'
    else
      redirect_to users_path
    end
  end

  def show
    @user = User.find(params[:id])
    @plans = @user.plan
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


  private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :cellphone)
    end

end
