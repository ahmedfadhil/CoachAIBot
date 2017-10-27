class ChatsController < ApplicationController
  before_action :authenticate_coach_user!
  respond_to :html, :js
  layout 'profile'

  def chat
    @user = User.find(params[:id])
  end

  def create

  end
end
