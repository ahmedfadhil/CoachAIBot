class ActivitiesController < ApplicationController
  layout 'profile'

  def show
    @activity = Activity.find(params[:id])
  end

  #tutte le attivita -> solo nel menu attivita del drawer
  def index
    @activities = Activity.all
  end

  def new
    @activity = Activity.new
  end

  # receives activity attributes and tries to create a new_assign activity
  def create
    @activity = Activity.new activity_params
    if !@activity.save
      error
    else
      if params[:new]
        redirect_to new_assign_activities_path
      else
        redirect_to activities_path
      end
    end
  end

  def edit
  end

  def update
    @activity = Activity.find(params[:id])
    if !@activity.update(activity_params)
      error
    else
      redirect_to activities_path
    end
  end

  def destroy
    activity = Activity.find(params[:id])
    if !activity.destroy
      error
    else
      flash[:destroyed] = 'La tua attivita\' e\' stata eliminata con successo!'
      redirect_to activities_path
    end
  end

  def new_assign
    @activity = Activity.new
    @activities = Activity.all
    @plan = Plan.find(params[:p_id])
    @user = User.find(params[:u_id])
  end

  def assign
    @activity = Activity.find(params[:a_id])
    @plan = Plan.find(params[:p_id])
    @user = User.find(params[:u_id])
    if !(@plan.activity<<@activity)
      error
    end
    redirect_to user_path(@user)
  end

  def dissociate
    plan = Plan.find(params[:p_id])
    user = User.find(params[:u_id])

    activity = plan.activity.find(params[:a_id])
    if activity
      plan.activity.delete(activity)
    end
    if plan.save
      redirect_to user_path(user)
    else
      redirect_to error
    end
  end

  private

    def activity_params
      params.require(:activity).permit(:name, :desc, :a_type, :category, :n_times)
    end

    def error
      render 'error/error'
    end


end
