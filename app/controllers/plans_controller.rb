class PlansController < ApplicationController
  layout 'profile'

  def new
    @plan = Plan.new
    @user = User.find params[:u_id]
  end

  def create
    plan = Plan.new plan_params
    plan.delivered = 0
    user_id = User.find params[:u_id]
    if plan.save
      user_id.plans << plan
      flash[:plan_saved] = 'Il nuovo piano e\' stato salvato con successo!'
    else
      flash[:plan_not_saved] = 'Siamo spiacenti ma non siamo riusciti a registrare il tuo piano, ricontrolla i dati inseriti!'
    end
    redirect_to user_path(user_id)
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

  def deliver
    plan = Plan.find(params[:p_id])

    # create notifications
    # call_rake :create_notifications, :plan_id => params[:p_id]
    system "rake --trace create_notifications  PLAN_ID=#{params[:p_id]} &"
    # %x(rake --trace create_notifications[#{params[:p_id]}])

    flash[:notice] = 'Consegnando il Piano...'
    redirect_to user_path(plan.user.id)
  end

  def suspend
    plan = Plan.find(params[:p_id])
    plan.delivered = 2
    if plan.save
      flash[:notice] = "Piano #{plan.name} Sospeso"
      redirect_to user_path(plan.user.id)
    else
      flash[:plan_not_suspended] = 'C\'e\' stato un problema e il piano non e\' stato sospeso! Ti preghiamo di riprovare piu\' tardi!'
      error
    end
  end

  def stop
    plan = Plan.find(params[:p_id])
    plan.delivered = 3
    if plan.save
      flash[:notice] = "Piano #{plan.name} Interrotto"
      redirect_to user_path(plan.user.id)
    else
      flash[:plan_not_suspended] = 'C\'e\' stato un problema e il piano non e\' stato sospeso! Ti preghiamo di riprovare piu\' tardi!'
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
