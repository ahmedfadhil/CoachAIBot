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

  def edit
    if !params[:id]
      @user = User.new(user_params)
      if !@user.save
        render 'error/error.html.erb'
      end
    else
      @user = User.find(user_id)
    end
  end

  # active users
  def active
    @users = User.all.limit 3
  end

  #suspended users
  def suspended
    @users = User.all.limit 10
  end

  #archived users
  def archived
    @users = User.all.limit 4
  end


  private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :cellphone)
  end

  def user_id
    params.require(:user).permit(:id)
  end

end
