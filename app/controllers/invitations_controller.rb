require 'csv_data/user_export'
class InvitationsController < ApplicationController
  layout 'profile'
  before_action :set_attributes, only: [:create]

  # GET /invitations
  def index
    @campaigns = Invitation.where('campaign IS NOT NULL').map(&:campaign).uniq
    @campaigns = Invitation.all.order('created_at DESC').limit(10)


    respond_to do |format|
      format.html
      format.csv {send_data @campaigns.to_csv}

    end


  end



  #invitation = Invitation.find(params[:id]).questionnaire.questionnaire_questions
  # Invitation.last.user
  # Invitation.last.questionnaire_answers.last.questionnaire_question
  # Invitation.last.questionnaire.questionnaire_questions.last.options
  # Invitation.last.user.tag_list
  #




  # GET /invitations/1
  def show
    @campaign = {}
    #@campaign[:title] = params[:title]
    push_users(@campaign)
    invitation = Invitation.find(params[:id])
    @campaign[:tag_list] = invitation.tag_list
    @campaign[:campaign_title] = invitation.campaign
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
	 # Remove the user id from the session
	 @campaign = Invitation.find(params[:id]).destroy
	 redirect_to invitations_path
 end


  # Download data into csv
  def save_all_questionnaire_data

    csv = QuestionnaireExport.all_questionnaire_data.to_csv.string
    # User.find_each do |user|
    #   csv << "\n Username: #{user.first_name} #{user.last_name} [User TAG: #{user.tag_list}]"
    # end
    send_data(csv,
              filename: 'allQuestionnaireData.csv',
              type: 'text/csv',
              disposition: 'attachment')
  end

  # def saveUserData
  #   user = User.find(params[:id])
  #   csv = UserExport.userData(user).to_csv.string
  #   csv << "\n Username: #{user.first_name} #{user.last_name}[User TAG: #{user.tag_list}]"
  #   send_data(csv,
  #             filename: 'userData.csv',
  #             type: 'text/csv',
  #             disposition: 'attachment')
  # end


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
