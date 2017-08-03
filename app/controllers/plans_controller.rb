class PlansController < ApplicationController
  layout 'profile'

  def new
    @plan = Plan.new
    @user = Patient.find params[:u_id]
  end

  def create
    plan = Plan.new plan_params
    user = Patient.find params[:u_id]
    if plan.save
      user.plans << plan
      flash[:plan_saved] = 'Il nuovo piano e\' stato salvato con successo!'
    else
      flash[:plan_not_saved] = 'Siamo spiacenti ma non siamo riusciti a registrare il tuo piano, ricontrolla i dati inseriti!'
    end
    redirect_to user_path(user)
  end

  def destroy
    plan = Plan.find(params[:p_id])
    if plan.destroy
      flash[:plan_destroyed] = 'Il piano e\' stato rimosso!'
      redirect_to user_path, id: params[:u_id]
    else
      flash[:plan_not_destroyed] = 'C\'e\' stato un problema e il piano non e\' stato rimosso! Ti preghiamo di riprovare piu\' tardi!'
      error
    end
  end

  private
    def plan_params
      params.require(:plan).permit(:name, :desc, :from_day, :to_day, :notification_hour_coach_def)
    end

    def error
      render 'error/error.html.erb'
    end
end
