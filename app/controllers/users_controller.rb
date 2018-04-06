require './lib/modules/chart_data_binder'

class UsersController < ApplicationController
  before_action :authenticate_coach_user!
  respond_to :html, :js
  layout 'profile'
  ARCHIVED = 'ARCHIVED'
  REGISTERED = 'REGISTERED'
  
  def index
    @users = User.where('coach_user_id = ? AND state <> ?', current_coach_user.id, ARCHIVED)
    @users = @users.paginate(:page => params[:page], per_page: 12).order('created_at DESC')
    # @users = User.find(params[:id]).invitations.last.questionnaire.questionnaire_questions.last.options.last.score
    
    
    respond_to do |format|
      format.html
      format.csv {send_data @users.to_csv}
    end
  
  end
  
  def new
    @user = User.new
  end
  
  def create
    user = User.new(user_params)
    user.state = REGISTERED
    if user.valid?
      user.save!
      create_command_data(user)
      current_coach_user.users << user
      features = assign_questionnaires user
      if features.nil?
        flash[:err] = "C'é stato un problema interno e l'utente non é stato inserito, riprova piú tardi!"
      else
        flash[:OK] = 'Utente inserito con successo!'
      end
    else
      flash[:err] = 'Utente non inserito!'
      flash[:errors] = user.errors.messages
    end
    redirect_to users_path
  end
  
  def show
    @user = User.find(params[:id])
    
    
   
    
    # @user = User.find(params[:id]).invitations
    
    
    respond_to do |format|
      format.html
      format.csv {send_data @user.to_csv}
    end
  
  end
  
  def features
    @user = User.find(params[:id])
  
  
  end
  
  #archived users
  def archived
    @users = User.where(:state => ARCHIVED)
  end
  
  def plans
    @user = User.find(params[:id])
  end
  
  def active_plans
    @user = User.find(params[:id])
    @plans = @user.plans.where(:delivered => 1)
  end
  
  def suspended_plans
    @user = User.find(params[:id])
    @plans = @user.plans.where(:delivered => 2)
  end
  
  def interrupted_plans
    @user = User.find(params[:id])
    @plans = @user.plans.where(:delivered => 3)
  end
  
  def finished_plans
    @user = User.find(params[:id])
    @plans = @user.plans.where(:delivered => 4)
  end
  
  
  def get_charts_data
    user = User.find(params[:id])
    data = ChartDataBinder.new.get_overview_data(user)
    render json: data, status: :ok
  end
  
  def get_plans_pdf
    user = User.find(params[:id])
    @plans = user.plans
    
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{user.first_name}-Plans",
               template: 'users/user_plans',
               show_as_html: params.key?('debug'),
               dpi: '250',
               # orientation: 'Landscape',
               viewport: '1280x1024',
               footer: {right: '[page] of [topage]'}
      end
    end
  end
  
  def get_feedbacks_to_do_pdf
    @plans = Plan.joins(plannings: :notifications).where('notifications.date<=? AND notifications.done=? AND plans.delivered=? AND plans.user_id=?', Date.today, 0, 1, params[:id]).uniq
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{@plans[0].user.first_name}-Plans",
               template: 'users/user_feedbacks',
               show_as_html: params.key?('debug'),
               dpi: '250',
               # orientation: 'Landscape',
               viewport: '1280x1024',
               footer: {right: '[page] of [topage]'}
      end
    end
  end
  
  def get_scores
    data = ChartDataBinder.new.get_scores(current_coach_user)
    render json: data, status: :ok
  end
  
  def get_images
    data = ChartDataBinder.new.get_images(current_coach_user)
    render json: data, status: :ok
  end
  
  def archive
    user = User.find(params[:id])
    user.state = ARCHIVED
    user.save!
    flash[:OK] = 'Utente ARCHIVIATO con successo!'
    redirect_to users_path
  end
  
  def restore #from archived
    user = User.find(params[:id])
    user.state = REGISTERED
    user.save!
    flash[:OK] = 'Utente RIATTIVATO con successo!'
    redirect_to users_path
  end
  
  def destroy
    user = User.find(params[:id])
    user.destroy
    flash[:OK] = 'Utente ELIMINATO con successo!'
    redirect_to users_path
  end
  
  
  # Download data into csv
  # def saveAllData
  #   csv = UserExport.allData.to_csv.string
  #   send_data(csv,
  #             filename: 'allData.csv',
  #             type: 'text/csv',
  #             disposition: 'attachment')
  # end
  
  
  private
  
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :cellphone, :age, :patient_objective, :gender,
                                 :height, :weight, :blood_type, :tag_list)
  end
  
  def assign_questionnaires(user)
    params[:questionnaires_ids].each do |id|
      questionnaire = Questionnaire.find(id)
      if Questionnaire.where(initial: false)
        Invitation.create(user: user, questionnaire: questionnaire, completed: false)
      else
        Questionnaire.where(initial: true).each do |questionnaire|
          Invitation.create(user: user, questionnaire: questionnaire, completed: false)
        end
      end
    end
  end
  
  
  def create_command_data(user)
    BotCommand.create(data: {}.to_json, user: user)
  end

end
