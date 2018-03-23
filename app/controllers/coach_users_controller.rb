class CoachUsersController < ApplicationController
  
  def index
    # @coaches = CoachUser.where('coach_user_id = ?', current_coach_user.id)
    @coaches = CoachUser.find(params[:id])
  end
  
  
  def create
    @coach = CoachUser.create(coach_params)
  end
  #
  #
  # def new
  #   @coach = CoachUser.new
  # end
  #
  
  def show
    @coach = CoachUser.find(params[:id])
 
    
  end
  def destroy
    @coach.avatar = nil
    @coach.save
  end
  private
  
  def coach_params
    params.require(:coach).permit(:first_name, :last_name, :email, :password, :password_confirmation, :avatar)
  end
end


