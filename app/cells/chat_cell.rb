class ChatCell < Cell::ViewModel
  def show
    render
  end

  def user_status
    render
  end

  def user
    model
  end

  def messages
    user.chats
  end

  def new_chat
    Chat.new user_id: user.id, coach_user_id: user.coach_user.id, direction: false
  end
end
