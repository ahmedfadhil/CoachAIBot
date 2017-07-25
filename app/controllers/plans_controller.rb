class PlansController < ApplicationController
  layout 'profile'

  def new
    @plan = Plan.new
    @user = User.find params[:u_id]
  end

  def create
    @plan = Plan.new plan_params
    @user = User.find params[:u_id]
    @plan.coach_user = current_coach_user
    if @plan.save
      if @user.plan << @plan
        flash[:plan_saved] = 'Il piano e\' stato salvato con successo!'
      else
        flash[:plan_not_assigned] = 'Non siamo riusciti ad assegnare il piano al paziente, ci scusiamo per il disagio!'
      end
    else
      flash[:plan_not_saved] = 'Siamo spiacenti ma non siamo riusciti a registrare il tuo piano, ricontrolla i dati inseriti!'
    end
    redirect_to user_path(@user)
  end

  def destroy
    plan = Plan.find(params[:p_id])
    if plan.destroy
      if plan.save
        flash[:plan_destroyed] = 'Il piano e\' stato rimosso!'
      else
        flash[:plan_not_destroyed] = 'C\'e\' stato un problema e il piano e\' stato rimosso!'
      end
    else
      flash[:plan_not_destroyed] = 'C\'e\' stato un problema e il piano e\' stato rimosso!'
    end
    redirect_to user_path, id: params[:u_id]
  end

  private
    def plan_params
      params.require(:plan).permit(:name, :desc, :from_day, :to_day)
    end
end
