class ActivitiesController < ApplicationController
  layout 'profile'

  def show
    @activity = Activity.find(params[:id])
  end

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
  end

  def assign
    @activity = Activity.find(params[:a_id])
    @plan = Plan.find(params[:plan_id])
    @user = User.find(params[:user_id])
    @users_plan = PlansActivity.new activity: @activity, plan: @plan
    if @users_plan.save
      redirect_to user_path, :user_id => @user.id
    end
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
