class ProfileController < ApplicationController
  before_action :authenticate_coach_user!

  def index
    @coach = current_coach_user
  end
end
