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
    redirect_to compute_destination(communication)
  end

  def all
    @communications = Communication.where(:coach_user_id => params[:id])
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
