class PlanningsController < ApplicationController

  layout 'profile'

  def new
    @activity = Activity.new
    @plan_id = params[:p_id]
    @user_id = params[:u_id]
  end

  def assign
    @activities = Activity.all
    @plan_id = params[:p_id]
    @user_id = params[:u_id]
  end

  def create
    activity = get_or_create_activity params
    planning = Planning.new(:activity_id =>activity.id, :plan_id => params[:p_id])
    unless activity.id.nil?
      if planning.save
        if completeness_question(planning)
          flash[:OK] = 'Attivita creata/assegnata con successo!'
        else
          flash[:err] = 'C\'e\' stato un problema durante la creazione delle domande di verifica. Ci scusiamo e la invitiamo a riprovare piu\' tardi!'
          flash[:errors] = planning.errors.messages
        end
      else
        flash[:err] = 'C\'e\' stato un problema durante l\'assegnamento dell\'attivit\a\'. Ci scusiamo e la invitiamo a riprovare piu\' tardi!'
        flash[:errors] = planning.errors.messages
      end
    end
    redirect_to plans_users_path(User.find(params[:u_id]))
  end

  def edit
    @planning = Planning.find(params[:id])
    @plan_id = @planning.plan.id
  end

  def update
    planning = Planning.find (params[:id])
    if planning.update (allowed_params)
      flash[:OK] = 'Pianificazione inserita con successo!'
    else
      flash[:err] = "La pianificazione non e' stata inserita!"
      flash[:errors] = planning.errors.messages
    end
    redirect_to plans_users_path(planning.plan.user)
  end

  def destroy
    planning = Planning.find(params[:id])
    if planning.destroy
      flash[:OK] = 'La tua attivita\' e\' stata rimossa dal piano con successo!'
    else
      flash[:err] = 'C\'e\' stato un problema durante la rimozione dell\'attivit\a\' dal piano.'
      flash[:errors] = planning.errors.messages
    end
    redirect_back fallback_location: root_path
  end

  def destroy_all_schedules
    planning = Planning.find(params[:p_id])
    planning.schedules.delete_all
    redirect_back fallback_location: root_path
  end

  private

    def activity_params
      params.require(:activity).permit(:name, :desc, :a_type, :category, :n_times)
    end

    def allowed_params
      params.require(:planning).permit!
    end


  def get_or_create_activity(params)
    if params['new'].nil?
      Activity.find(params['a_id'])
    else
      activity = Activity.new(params.require(:activity).permit(:name, :desc, :a_type, :category, :n_times))
      activity.coach_user = current_coach_user
      unless activity.save
        flash[:err] = 'C\'e\' stato un problema durante la creazione dell\'attivit\a\'. Ci scusiamo e la invitiamo a riprovare piu\' tardi!'
        flash[:errors] = activity.errors.messages
      end
      activity
    end
  end

  def completeness_question(planning)
    question = Question.new text: "Hai portato a termine l'attivita'  ''#{planning.activity.name}'' ?", q_type: 'completeness'
    question.planning = planning
    if question.save
      answer1 = Answer.new text: 'Si'
      answer2 = Answer.new text: 'No'
      answer1.question = question
      answer2.question = question
      answer1.save && answer2.save ? true : false
    end
  end
end
