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

  # receives activity attributes and tries to create a new activity
  def create

    @activity = Activity.new activity_params
    if !@activity.save
      error
    else
      redirect_to activities_path
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
    @activity = Activity.find(params[:id])
    if !@activity.destroy
      error
    else
      flash[:destroyed] = 'La tua attivita\' e\' stata eliminata con successo!'
      redirect_to activities_path
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
