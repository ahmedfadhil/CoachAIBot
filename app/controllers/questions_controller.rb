class QuestionsController < ApplicationController
  layout 'profile'

  def new
    @question = Question.new
    @activity = Activity.find(params[:a_id])
    @user = User.find(params[:u_id])
    @plan_id = params[:p_id]
  end

  def create
    activity = Activity.find(params[:a_id])
    user = User.find(params[:u_id])
    question = Question.new(question_params)
    question.activity_id = params[:a_id]
    if !question.save
      flash[:err] = 'Ce stato un problema durante il SALVATAGGIO DELLA DOMANDA! Riprova piu tardi!'
      flash[:errors] = question.errors.messages
    else
      flash[:OK] = 'Domanda salvata con successo!'
      activity.questions << question
      case question.q_type
        when 'yes_no'
          answer1 = Answer.new(text: 'si')
          answer2 = Answer.new(text: 'no')
          if !answer1.save || !answer2.save
            flash[:err] = 'Ce stato un problema durante il salvataggio delle risposte SI/NO! Riprova piu tardi!'
            flash[:errors] = answer1.errors.messages
          else
            question.answers << answer1
            question.answers << answer2
          end
        when 'scalar'
          (params[:scalar_from_val].to_i..params[:scalar_to_val].to_i).each do |i|
            answer = Answer.new(text: i)
            if answer.save
              puts answer.text
              question.answers << answer
            else
              flash[:err] = 'Ce stato un problema durante il salvataggio delle risposte NUMERICHE! Riprova piu tardi!'
              flash[:errors] = answer.errors.messages
            end
          end
        else
          open_answers = params[:open_answer_val]
          open_answers.split(',').each do |i|
            answer = Answer.new(text: i)
            if answer.save
              question.answers << answer
            else
              flash[:err] = 'Ce stato un problema durante il salvataggio delle risposte alla DOMANDA APERTA! Riprova piu tardi!'
            end
          end
      end
      redirect_to plans_users_path(user)
    end
  end

  def destroy
    question = Question.find(params[:id])
    if question.destroy
      flash[:OK] = 'La domanda\' e\' stata eliminata con successo!'
    else
      flash[:err] = 'Ce stato un problema e la domanda\' NON e\' stata eliminata! La preghiamo di riprovare piu\' tardi'
      flash[:errors] = question.errors.messages
    end
    redirect_back fallback_location: root_path
  end

  private

    def question_params
      params.require(:question).permit(:text, :q_type)
    end
  
end
