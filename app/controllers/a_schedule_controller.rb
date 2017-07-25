class AScheduleController < ApplicationController
  layout 'profile'

  def new
    @schedule = ASchedule.new
    @a_id = params[:a_id]
    @u_id = params[:u_id]
  end

  def create
    schedule = ASchedule.new schedule_params
    activity = Activity.find params[:a_id]
    if schedule.save
      flash[:scheduled] = 'L\'orario\' e\' stato registrato. '
      if activity.a_schedule << schedule
        if activity.save
          flash[:assigned] = 'L\'orario\' e\' stato assegnato all\'attivita\'. '
        else
          flash[:assigned] = 'L\'orario\' NON e\' stato assegnato all\'attivita\'. Ti invitiamo a riprovare piu\' tardi! '
        end
      else
        flash[:assigned] = 'L\'orario\' NON e\' stato assegnato all\'attivita\'. Ti invitiamo a riprovare piu\' tardi! '
      end
    else
      flash[:scheduled] = ' C\'e\' stato un problema e l\'orario\' non e\' stato registrato. Ti invitiamo a riprovare piu tardi. '
    end
    redirect_to user_path(User.find(params[:u_id]))
  end

  private

    def schedule_params
      params.require(:a_schedule).permit(:day, :time, :date)
    end
end
