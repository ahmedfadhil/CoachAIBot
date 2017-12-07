class ChatCell < Cell::ViewModel
  def show
    render
  end

  def user_status
    render
  end

  def user_not_profiled
    render
  end

  def user
    options[:user]
  end

  def chats
    model
  end

  def new_chat
    Chat.new user_id: user.id, coach_user_id: user.coach_user.id, direction: false
  end
end
