class CalendarController < ApplicationController
  # layout 'profile'
  before_action :authenticate_coach_user!
  
  def index
  end
  
  
end
