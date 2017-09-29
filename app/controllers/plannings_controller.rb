class PlanningsController < ApplicationController
  layout 'profile'

  def new
    @activity = Activity.new
    @activities = Activity.all
    @plan = Plan.find(params[:p_id])
    @user = User.find(params[:u_id])
  end

  def create
    planning = Planning.new(:activity_id => (get_or_create_activity params[:new], params).id, :plan_id => params[:p_id])
    if planning.save
      flash[:notice] = 'Attivita creata/assegnata con successo!'
    else
      flash[:notice] = 'C\'e\' stato un problema durante l\'assegnamento dell\'attivit\a\'. Ci scusiamo e la invitiamo a riprovare piu\' tardi!'
    end
    redirect_to plans_users_path(User.find(params[:u_id]))
  end

  def edit
    @planning = Planning.find(params[:id])
  end

  def update
    planning = Planning.find (params[:id])
    if planning.update (allowed_params)
      flash[:notice] = 'Orari creati con successo!'
    else
      flash[:notice] = 'C\'e\' stato un problema durante la creazione degli orari. Ci scusiamo e la invitiamo a riprovare piu\' tardi!'
    end
    redirect_to plans_users_path(planning.plan.user)
  end

  def destroy
    planning = Planning.find(params[:id])
    if !planning.destroy
      flash[:notice] = 'C\'e\' stato un problema durante la rimozione dell\'attivit\a\' dal piano. Ci scusiamo e la invitiamo a riprovare piu\' tardi!'
    else
      flash[:notice] = 'La tua attivita\' e\' stata rimossa dal piano con successo!'
    end
    redirect_back fallback_location: root_path
  end

  private

    def activity_params
      params.require(:activity).permit(:name, :desc, :a_type, :category, :n_times)
    end

    def allowed_params
      params.require(:planning).permit!
    end


    def completeness_question(activity)
      question = Question.new text: "Hai portato a termine l'attivita'  ''#{activity.name}'' ?", q_type: 'completeness'
      question.activity = activity
      if question.save
        answer1 = Answer.new text: 'Si'
        answer2 = Answer.new text: 'No'
        answer1.question = question
        answer2.question = question
        answer1.save && answer2.save ? true : false
      end
    end

  def get_or_create_activity(bool_param, params)
    if bool_param.nil?
      Activity.find(params[:a_id])
    else
      activity = Activity.new(params.require(:activity).permit(:name, :desc, :a_type, :category, :n_times))
      if !activity.save
        flash[:notice] = 'C\'e\' stato un problema durante la creazione dell\'attivit\a\'. Ci scusiamo e la invitiamo a riprovare piu\' tardi!'
        activity
      else
        # add the default completeness verify method
        unless completeness_question(activity)
          flash[:notice] = 'C\'e\' stato un problema durante la creazione dei metodi di verifica dell\'attivit\a\'. Ci scusiamo e la invitiamo a riprovare piu\' tardi!'
        end
      end
    end
  end
end
