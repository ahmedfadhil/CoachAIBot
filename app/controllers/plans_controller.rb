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
      flash[:OK] = 'Il nuovo piano è stato salvato con successo!'
    else
      flash[:err] = 'Siamo spiacenti ma non siamo riusciti a registrare il tuo piano, ricontrolla i dati inseriti!'
      flash[:errors] = plan.errors.messages
    end
    redirect_to plans_users_path(User.find(params['u_id']))
  end

  def destroy
    plan = Plan.find(params[:p_id])
    call_task_notify_deleted_plan(plan.name, plan.user.id)
    if plan.destroy
      flash[:OK] = 'Il piano è stato rimosso!'
    else
      flash[:err] = 'C\'è stato un problema e il piano non è stato rimosso! Ti preghiamo di riprovare più tardi!'
      flash[:errors] = plan.errors.messages
    end
    redirect_to plans_users_path(plan.user.id)
  end

  def deliver
    plan = Plan.find(params[:p_id])
    if plan.plannings.count == 0
      flash[:err] = "Piano NON CONSEGNATO - Un piano deve avere almeno 1 attivita' per essere consegnato!"
    else
      plan.delivered = 1
      if plan.save
        call_tasks params[:p_id]
        flash[:OK] = 'Consegnando il Piano...'
      else
        flash[:err] = 'Piano NON CONSEGNATO'
        flash[:errors] = plan.errors.messages
      end
    end
    redirect_to plans_users_path(plan.user.id)
  end

=begin
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
=end

  private
    def plan_params
      params.require(:plan).permit(:name, :desc, :from_day, :to_day, :notification_hour_coach_def)
    end

    def call_task_notify_deleted_plan(plan_name, user_id)
      system "rake --trace notify_deleted_plan  PLAN_NAME='#{plan_name}' USER_ID=#{user_id} &"
    end

    def call_tasks(plan_id)
      # create notifications
      # call_rake :create_notifications, :plan_id => params[:p_id]
      system "rake --trace create_notifications  PLAN_ID=#{plan_id} &"
      system "rake --trace notify_for_new_activities  PLAN_ID=#{plan_id} &"
      # %x(rake --trace create_notifications[#{params[:p_id]}])
    end
end
