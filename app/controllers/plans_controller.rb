class PlansController < ApplicationController
  layout 'profile'

  def new
    @plan = Plan.new
    @user = User.find params[:u_id]
  end

  def create
    plan = Plan.new plan_params
    plan.delivered = 0
    plan.user_id = params['u_id']
    if plan.save
      flash[:OK] = 'Il nuovo piano e\' stato salvato con successo!'
    else
      flash[:err] = 'Siamo spiacenti ma non siamo riusciti a registrare il tuo piano, ricontrolla i dati inseriti!'
      flash[:errors] = plan.errors.messages
    end
    redirect_to plans_users_path(User.find(params['u_id']))
  end

  def destroy
    plan = Plan.find(params[:p_id])
    if plan.destroy
      flash[:OK] = 'Il piano e\' stato rimosso!'
    else
      flash[:err] = 'C\'e\' stato un problema e il piano non e\' stato rimosso! Ti preghiamo di riprovare piu\' tardi!'
      flash[:errors] = plan.errors.messages
    end
    redirect_to plans_users_path(plan.user.id)
  end

  def deliver
    plan = Plan.find(params[:p_id])
    if plan.user.profiled? && plan.has_plannings?
      plan.delivered = 1
      if plan.save
        # create notifications
        # call_rake :create_notifications, :plan_id => params[:p_id]
        system "rake --trace create_notifications  PLAN_ID=#{params[:p_id]} &"
        system "rake --trace notify_for_new_activities  PLAN_ID=#{params[:p_id]} &"
        # %x(rake --trace create_notifications[#{params[:p_id]}])

        flash[:OK] = 'Consegnando il Piano...'
      else
        flash[:err] = 'Piano non consegnato. Forse ce stato un problema, la preghiamo di riprovare piu\' tardi.'
        flash[:errors] = plan.errors.messages
      end
    else
      flash[:err] = "PIANO NON CONSEGNATO! Il piano non contiene attivita' oppure il paziente al quale stai cercando di consegnare il piano non ha ancora completato i questionari. Riceverai una notifica non appena questo succedera"
    end



    redirect_to plans_users_path(plan.user.id)
  end

  def suspend
    plan = Plan.find(params[:p_id])
    plan.delivered = 2
    if plan.save
      flash[:OK] = "Piano #{plan.name} Sospeso!"
    else
      flash[:err] = 'C\'e\' stato un problema e il piano non e\' stato sospeso! Ti preghiamo di riprovare piu\' tardi!'
      flash[:errors] = plan.errors.messages
    end
    redirect_to plans_users_path(plan.user.id)
  end

  def stop
    plan = Plan.find(params[:p_id])
    plan.delivered = 3
    if plan.save
      flash[:OK] = "Piano #{plan.name} Interrotto"
    else
      flash[:err] = 'C\'e\' stato un problema e il piano non e\' stato sospeso! Ti preghiamo di riprovare piu\' tardi!'
      flash[:errors] = plan.errors.messages
    end
    redirect_to plans_users_path(plan.user.id)
  end

  private
    def plan_params
      params.require(:plan).permit(:name, :desc, :from_day, :to_day, :notification_hour_coach_def)
    end
end
