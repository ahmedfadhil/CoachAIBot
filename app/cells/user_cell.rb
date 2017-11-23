require './lib/bot/image_solver'

class UserCell < Cell::ViewModel
  def show
    render
  end

  def user
    model
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

  def default_image
    'rsz_user_icon.png'
  end

end
