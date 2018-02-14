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
        'self_img_avatar.png'
      else
        'other_img_avatar.png'
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

end
