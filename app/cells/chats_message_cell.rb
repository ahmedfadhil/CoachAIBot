class ChatsMessageCell < Cell::ViewModel
  include ActionView::Helpers::TagHelper

  def show
    render
  end

  def message
    model
  end

  def text
    message.text
  end

  def style
    case message.direction
      when false      #coach to patient
        'self'
      else           #patient to coach
        'other'
    end
  end

  def img
    case message.direction
      when false
        'logo.png'
      else
        user_profile_image(message.user)
    end
  end

  def time
    message.created_at.strftime '%H:%M'
  end


  def li_message &block
    content_tag :li, class: style, &block
  end

  def img_style
    image_tag img, draggable: false
  end

  def div_personal &block
    content_tag :div, class: 'messages', data: {id: message.id}, &block
  end


  def user_profile_image(user)
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
    'user.jpg'
  end
end
