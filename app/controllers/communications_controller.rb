class CommunicationsController < ApplicationController
  layout 'profile'

  # used to pool coach's communications
  def lasts
    after = 0
    after = params[:after] if params[:after].to_i >= 0
    @communications = Communication.where('id > ? AND coach_user_id = ? AND (read_at is ? OR read_at >= ? )', after, params[:id], nil, Time.now - 60.minutes)
  end

  def show
    communication = Communication.find(params[:id])
    communication.read_at = Time.now
    communication.save!
    patient = communication.user
    case communication.c_type
      when 0, 2
        redirect_to user_path(patient)
      when 1
        redirect_to features_users_path(patient)
      else
        redirect_to chat_chats_path(patient)
    end
  end

  def all
    @communications = Communication.where(:coach_user_id => params[:id])
  end
end
