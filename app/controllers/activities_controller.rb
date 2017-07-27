class ActivitiesController < ApplicationController
  layout 'profile'

  def show
    @activity = Activity.find(params[:id])
  end

  #tutte le attivita -> solo nel menu attivita del drawer
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
        redirect_to activities_path
      else
        error
      end
    else
      error
    end
  end

  def edit
  end

  def update
    activity = Activity.find(params[:id])
    if !activity.update(activity_params)
      error
    else
      redirect_to activities_path
    end
  end

  def destroy
    activity = Activity.find(params[:id])
    if !activity.destroy
      error
    else
      flash[:destroyed] = 'La tua attivita\' e\' stata eliminata con successo!'
      redirect_to activities_path
    end
  end


  private

    def activity_params
      params.require(:activity).permit(:name, :desc, :a_type, :category, :n_times)
    end

    def error
      render 'error/error'
    end

    def completness_question(activity)
      question = Question.new text: "Hai portato a termine l'attivita' #{activity.name}?", q_type: 'yes_no'
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
