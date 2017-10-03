require 'awesome_print'

class SchedulesController < ApplicationController
  layout 'profile'

  def new
    @schedule = Schedule.new

    @schedules = []
    @planning_id = params[:planning_id]
    @activity = Activity.find(params[:a_id])

    (1..@activity.n_times).each do |i|
      @schedules.push Schedule.new
    end

  end

  def create
    planning = Planning.find(params[:planning_id])
    flag = true
    saved_schedules = []

    schedules_params.each do |s_params|
      s = Schedule.new(s_params)
      if s.save
        saved_schedules.push s
      else
        flag = false
      end
    end


    if flag
      saved_schedules.each  do |schedule|
        planning.schedules << schedule
      end
      flash[:notice] = 'L\'orario\' e\' stato registrato con successo. '
    else
      flash[:notice] = ' C\'e\' stato un problema e l\'orario\' non e\' stato registrato. Ti invitiamo a riprovare piu tardi. '
    end
    redirect_to user_path(User.find(planning.plan.user.id))

  end

  def create2
    schedule = Schedule.new schedule_params
    planning = Planning.find(params[:planning_id])
    if schedule.save
      flash[:notice] = 'L\'orario\' e\' stato registrato con successo. '
      planning.schedules << schedule
    else
      flash[:notice] = ' C\'e\' stato un problema e l\'orario\' non e\' stato registrato. Ti invitiamo a riprovare piu tardi. '
    end
    redirect_to user_path(User.find(planning.plan.user.id))
  end

  def destroy
    schedule = Schedule.find(params[:id])
    if schedule.destroy
      flash[:notice] = 'L\'Orario e\' stato eliminata con successo!'
    else
      flash[:notice] = 'Ce stato un errore durante la distruzione dell\'ORARIO! La invitiamo a riprovare piu\' tardi!'
    end
    redirect_to plans_users_path(schedule.planning.plan.user)
  end

  private

    def schedule_params
      params.require(:schedule).permit(:day, :time, :date)
    end

    def schedules_params
      params.permit(:schedules => [])
    end
end
