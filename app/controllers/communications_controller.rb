class CommunicationsController < ApplicationController

  # used to pool coach's communications
  def all
    @communications = Communication.all
  end

  def show
    communication = Communication.find(params[:id])
    communication.read_at = Time.now
    communication.save!
    redirect_to compute_destination(communication)
  end

  private

  def compute_destination(communication)
    patient = communication.user
    case communication.c_type
      when 0, 2
        user_path(patient)
      when 1
        features_users_path(patient)
      else
        chat_chats_path(patient)
    end
  end
end
