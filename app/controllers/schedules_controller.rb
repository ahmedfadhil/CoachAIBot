class SchedulesController < ApplicationController
  layout 'profile'

  def new
    @schedule = Schedule.new
    @planning_id = params[:planning_id]
  end

  def create
    schedule = Schedule.new schedule_params
    planning = Planning.find(params[:planning_id])
    if schedule.save
      flash[:scheduled] = 'L\'orario\' e\' stato registrato con successo. '
      planning.schedules << schedule
      redirect_to user_path(Patient.find(planning.plan.user.id))
    else
      flash[:scheduled] = ' C\'e\' stato un problema e l\'orario\' non e\' stato registrato. Ti invitiamo a riprovare piu tardi. '
      error
    end

  end

  def destroy
    schedule = Schedule.find(params[:id])
    if schedule.destroy
      flash[:destroyed] = 'L\'Orario e\' stato eliminata con successo!'
      redirect_to user_path(Patient.find(schedule.planning.plan.user.id))
    else
      flash[:destroyed] = 'Ce stato un errore durante la distruzione dell\'ORARIO! La invitiamo a riprovare piu\' tardi!'
      error
    end
  end

  private

    def schedule_params
      params.require(:schedule).permit(:day, :time, :date)
    end

    def error
      render 'error/error'
    end
end
