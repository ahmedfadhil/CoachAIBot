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
        flash[:notice] = 'La tua attivita\' e\' stata AGGIUNTA con successo!'
      else
        flash[:notice] = 'C\'e\' stato un problema durante la crezione dell\'attivita\'! Contattare l\'amministratore del sistema se il problema persiste!'
      end
    else
      flash[:notice] = 'ATTIVITA NON INSERITA! C\'e\' stato un problema durante la crezione dell\'attivita\'! RICONTROLLA I DATI INSERITI!'
    end
    redirect_to activities_path
  end

  def edit
  end

  def update
    activity = Activity.find(params[:id])
    if !activity.update(activity_params)
      flash[:notice] = "L'Attivita e' stata modificata con successo!"
    else
      flash[:notice] = "C'e' stato un problema durante l'aggiornamento dell'attivita'. La preghiamo di ricontrollare i dati inseriti e riprovare."
    end
    redirect_to activities_path
  end

  def destroy
    activity = Activity.find(params[:id])
    if activity.destroy
      flash[:notice] = 'La tua attivita\' e\' stata eliminata con successo!'
    else
      flash[:notice] = "C'e' stato un problema durante la distruzione dell'attivita'. La preghiamo di riprovare piu' tardi."
    end
    redirect_to activities_path
  end


  private

    def activity_params
      params.require(:activity).permit(:name, :desc, :a_type, :category, :n_times)
    end

    def error
      render 'error/error'
    end

    def completness_question(activity)
      question = Question.new text: "Hai portato a termine l'attivita' #{activity.name}?", q_type: 'completeness'
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
