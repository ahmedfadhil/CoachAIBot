class QuestionsController < ApplicationController
  layout 'profile'

  def new
    @question = Question.new
    @activity = Activity.find(params[:a_id])
    @user = User.find(params[:u_id])
  end

  def create
    activity = Activity.find(params[:a_id])
    question = Question.new(question_params)
    user = User.find(params[:u_id])
    err = 0
    if !question.save
      flash[:error] = 'Ce stato un problema durante il SALVATAGGIO DELLA DOMANDA! Riprova piu tardi!'
      err = 1
    else
      activity.questions << question

      case question.q_type
        when 'yes_no'
          answer1 = Answer.new(text: 'si')
          answer2 = Answer.new(text: 'no')
          if !answer1.save || !answer2.save
            flash[:error] = 'Ce stato un problema durante il salvataggio delle risposte SI/NO! Riprova piu tardi!'
            err = 1
          else
            question.answers << answer1
            question.answers << answer2
          end
        when 'scalar'
          (params[:scalar_from_val].to_i..params[:scalar_to_val].to_i).each do |i|
            answer = Answer.new(text: i)
            if answer.save
              question.answers << answer
            else
              flash[:error] = 'Ce stato un problema durante il salvataggio delle risposte NUMERICHE! Riprova piu tardi!'
              err = 1
            end
          end
        else
          open_answers = params[:open_answer_val]
          open_answers.split(',').each do |i|
            answer = Answer.new(text: i)
            if answer.save
              question.answers << answer
            else
              flash[:error] = 'Ce stato un problema durante il salvataggio delle risposte alla DOMANDA APERTA! Riprova piu tardi!'
              err = 1
            end
          end
      end

      if err!=0
        error
      else
        redirect_to user_path(user.id)
      end
    end
  end

  private

    def question_params
      params.require(:question).permit(:text, :q_type)
    end

    def error
      render 'error/error'
    end
end
