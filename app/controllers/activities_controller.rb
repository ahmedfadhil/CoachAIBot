class ActivitiesController < ApplicationController
  layout 'profile'

  def show
    @activity = Activity.find(params[:id])
  end

  def index
    @activities = Activity.all
  end

  def new
    @activity = Activity.new
  end

  def create
    activity = Activity.new activity_params
    if activity.save
      #automaticaly add COMPLETNESS question
      if completness_question(activity)
        flash[:info] = 'La tua attivita\' e\' stata AGGIUNTA con successo!'
      else
        flash[:notice] = 'C\'e\' stato un problema durante la crezione dell\'attivita\', in particolare durante la creazione dei metodi di verifica/domande completezza automatiche! Contattare l\'amministratore del sistema se il problema persiste!'
        flash[:errors] = activity.errors.messages
      end
    else
      flash[:notice] = "L'Attivita NON E' STATA INSERITA"
      flash[:errors] = activity.errors.messages
    end
    redirect_to activities_path
  end

  def edit
  end

  def update
    activity = Activity.find(params[:id])
    if !activity.update(activity_params)
      flash[:info] = "L'Attivita e' stata modificata con successo!"
    else
      flash[:notice] = "C'e' stato un problema durante l'aggiornamento dell'attivita'. La preghiamo di ricontrollare i dati inseriti e riprovare."
      flash[:errors] = activity.errors.messages
    end
    redirect_to activities_path
  end

  def destroy
    activity = Activity.find(params[:id])
    if activity.destroy
      flash[:info] = 'La tua attivita\' e\' stata eliminata con successo!'
    else
      flash[:notice] = "C'e' stato un problema durante la distruzione dell'attivita'. La preghiamo di riprovare piu' tardi."
      flash[:errors] = activity.errors.messages
    end
    redirect_to activities_path
  end


  private

    def activity_params
      params.require(:activity).permit(:name, :desc, :a_type, :category, :n_times)
    end

    def completness_question(activity)
      question = Question.new text: "Hai portato a termine l'attivita' #{activity.name}?", q_type: 'completeness'
      question.activity = activity
      if question.save
        answer1 = Answer.new text: 'Si'
        answer2 = Answer.new text: 'No'
        answer1.question = question
        answer2.question = question
        answer1.save && answer2.save ? true : false
      end
    end

end
