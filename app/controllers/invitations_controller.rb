class InvitationsController < ApplicationController
  layout 'profile'
  before_action :set_attributes, only: [:create]

  # GET /invitations
  def index
    @campaigns = Invitation.where('campaign IS NOT NULL').map(&:campaign).uniq
  end

  # GET /invitations/1
  def show
    @campaign = {}
    @campaign[:title] = params[:title]
    push_users(@campaign)
    @campaign[:tag_list] = Invitation.where(campaign: @campaign[:title]).first.tag_list
  end

  # GET /invitations/new
  def new
  end

  # GET /invitations/1/edit
  def edit
  end

  # POST /invitations
  def create
    User.tagged_with(@tag_list).each do |user|
      
      invitation = Invitation.new(campaign: @title,questionnaire_id: @q_id,
                                  user_id: user.id, completed: false)
      invitation.tag_list = @tag_list
      invitation.save!
      #notify user that there is a new questionnaire to fulfill
      call_rake 'notify_for_new_questionnaire', user.id
    end
    redirect_to invitations_path
  end

  # DELETE /invitations/1
  def destroy
  
  end

  private
  
  def set_attributes
    @title = params[:campaign_title]
    @tag_list = params[:tag_list]
    @q_id = Questionnaire.where(title: params[:questionnaire_name]).first.id
  end
  
  def push_users(campaign_hash)
    campaign_hash[:users] = []
    User.joins(:invitations).where('invitations.campaign = ?', @campaign[:title]).each do |user|
      campaign_hash[:users].push({'user_id' => user.id, 'name' => "#{user.first_name} #{user.last_name}"})
    end
  end
  
end
