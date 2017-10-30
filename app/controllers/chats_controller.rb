class ChatsController < ApplicationController
  before_action :authenticate_coach_user!
  respond_to :html, :js
  layout 'profile'

  def chat
    @user = User.find(params[:id])
  end

  def create
    @chat = Chat.create(chat_params)
  end

  private
  def chat_params
    params.require(:chat).permit(:text, :user_id, :coach_user_id, :direction)
  end
end
