class QuestionsCell < Cell::ViewModel
  def show
    render
  end

  def planning
    model
  end
  
  def short_answers(question)
    answers = question.answers
    size = answers.size
      "#{answers[0].text}, ..., #{answers[size-1].text}"
  end

  def is_not_active(plan)
    plan.delivered != 1 && plan.delivered != 3
  end

end
