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

=begin
  #replaced with ajax calls
  def default_image
    'rsz_user_icon.png'
  end

  def profile_photo_url
    if user.telegram_id.nil?
      default_image
    else
      begin
        solver = ImageSolver.new
        solver.solve(user.telegram_id)
      rescue Exception
        default_image
      end
    end
  end
=end

end
