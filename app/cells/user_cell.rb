require './lib/bot_v2/image_solver'

class UserCell < Cell::ViewModel
  def show
    render
  end

  def user
    model
  end

  def archived?
    user.archived?
  end

  def archived_css_class
    if archived?
      'user_archived'
    end
  end



end
