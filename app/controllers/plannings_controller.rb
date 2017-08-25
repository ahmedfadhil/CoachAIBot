class PlanningsController < ApplicationController
  layout 'profile'

  def new
    @activity = Activity.new
    @activities = Activity.all
    @plan = Plan.find(params[:p_id])
    @user = User.find(params[:u_id])
  end

  def create
    if params[:new]
      activity = Activity.new(activity_params)
      if !activity.save
        flash[:error] = 'C\'e\' stato un problema durante la creazione dell\'attivit\a\'. Ci scusiamo e la invitiamo a riprovare piu\' tardi!'
        error
      else
        # add the default completness verify method
        if !completness_question(activity)
          flash[:error] = 'C\'e\' stato un problema durante la creazione dei metodi di verifica dell\'attivit\a\'. Ci scusiamo e la invitiamo a riprovare piu\' tardi!'
          error
        end
      end
    else
      activity = Activity.find(params[:a_id])
    end

    plan = Plan.find(params[:p_id])
    user = User.find(params[:u_id])
    planning = Planning.new
    planning.activity_id = activity.id
    planning.plan_id = plan.id
    if planning.save
      redirect_to user_path(user)
    else
      flash[:error] = 'C\'e\' stato un problema durante l\'assegnamento dell\'attivit\a\'. Ci scusiamo e la invitiamo a riprovare piu\' tardi!'
      error
    end
  end

  def edit
    @planning = Planning.find(params[:id])
  end

  def update
    @planning = Planning.find (params[:id])

    if @planning.update (allowed_params)
      redirect_to @planning.plan.user
    else
      flash[:error] = 'C\'e\' stato un problema durante la creazione degli orari. Ci scusiamo e la invitiamo a riprovare piu\' tardi!'
      error
    end
  end

  def destroy
    planning = Planning.find(params[:id])
    if !planning.destroy
      flash[:error] = 'C\'e\' stato un problema durante la rimozione dell\'attivit\a\' dal piano. Ci scusiamo e la invitiamo a riprovare piu\' tardi!'
      error
    else
      flash[:destroyed] = 'La tua attivita\' e\' stata rimossa dal piano con successo!'
      redirect_back fallback_location: root_path
    end
  end

  private

    def activity_params
      params.require(:activity).permit(:name, :desc, :a_type, :category, :n_times)
    end

    def allowed_params
      params.require(:planning).permit!
    end

    def error
      render 'error/error'
    end

    def completness_question(activity)
      question = Question.new text: "Hai portato a termine l'attivita'  ''#{activity.name}'' ?", q_type: 'yes_no'
      question.activity = activity
      if question.save
        answer1 = Answer.new text: 'Si'
        answer2 = Answer.new text: 'No'
        answer1.question = question
        answer2.question = question
        if answer1.save && answer2.save
          true
        else
          false
        end
      end
    end
end
