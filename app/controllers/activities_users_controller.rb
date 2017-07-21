class ActivitiesUsersController < ApplicationController
  layout 'profile'


  #tutte le attivita -> solo nel menu attivita del drawer
  def index
  end

  def new
    @activities = Activity.all
    @activity = Activity.new
    @user = User.find(params[:user_id])
    @plan_id = params[:plan_id]
  end

  def create
    @activity = Activity.new(activity_params)
    if !@activity.save
      render 'error/error.html.erb'
    end
    #redirect_to new_activity_path, user_id: @user_id
    render activities_user_path
  end

  def assign
    @activity = Activity.find(params[:id])
    @plan = Plan.find(params[:plan_id])
    if !(@plan.activity<<@activity)
      render 'error/error.html.erb'
    end
    redirect_to user_path, id: @plan.user.id
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def activity_params
    params.require(:activity).permit(:name, :desc, :a_type, :category, :n_times)
  end




end
