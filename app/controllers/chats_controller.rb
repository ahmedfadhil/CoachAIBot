require './lib/modules/notifier'

class ChatsController < ApplicationController
  before_action :authenticate_coach_user!
  respond_to :html, :js
  layout 'profile'

  def chat
    @user = User.find(params[:id])
    @chats = @user.chats
  end

  def create
    @chat = Chat.create(chat_params)
    Notifier.new.notify_for_new_messages(@chat.user)
  end

  def chats
    @chats = Chat.where('user_id = ? AND id > ?', params[:id], params[:after].to_i)
  end

  private
  def chat_params
    params.require(:chat).permit(:text, :user_id, :coach_user_id, :direction)
  end
end
