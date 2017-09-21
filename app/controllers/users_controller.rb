require 'bot_classes/general_actions'
require 'securerandom'

class UsersController < ApplicationController
  before_action :authenticate_coach_user!
  respond_to :html, :js
  layout 'profile'

  def index
    @users = User.where(coach_user_id: current_coach_user.id)
  end

  def new
    @user = User.new
  end

  def create
    user = User.new(user_params)
    if user.save
      current_coach_user.users << user
      feature = Feature.new(physical: 0, health: 0, mental: 0, coping: 0, user_id: user.id)
      feature.save
      redirect_to users_path
    else
      flash[:error] = 'Errore durante il salvataggio dell\'utente! '
      error
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def features
    @user = User.find(params[:id])
    @features = @user.feature
  end

  def get_charts_data
    user = User.find(params[:id])
    plans = user.plans.where(delivered: 1)


    respond_to do |format|
      format.json do
        render json: {status: 'ok'}
      end
    end
  end

  # active users
  def active
    @users = User.all.limit 1
    render 'users/index'
  end

  #suspended users
  def suspended
    @users = User.all.limit 10
    render 'users/index'
  end

  #archived users
  def archived
    @users = User.all.limit 4
    render 'users/index'
  end

  def plans
    @user = User.find(params[:id])
    @plans = @user.plans
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

  def get_plans_pdf
    user = User.find(params[:id])
    @plans = user.plans

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{user.first_name}-Plans",
               template: 'users/user_plans',
               show_as_html: params.key?('debug'),
               disable_smart_shrinking: true
               #dpi: '400'
      end
    end
  end


	def wearables
		@user = User.find(params[:id])
	end

	def fitbit_invite
		@user = User.find(params[:id])

		# create a new identity token for the selected user
		@user.identity_token = SecureRandom.hex
		@user.save!

		url = wearables_fitbit_connect_url(token: @user.identity_token)
		message1 = "Hai ricevuto un invito dal coach a collegare il tuo dispositivo indossabile"
		message2 = "Perfavore visita il seguente indirizzo per continuare: #{url}"

		ga = GeneralActions.new(@user, JSON.parse(@user.bot_command_data))
		ga.send_reply(message1)
		ga.send_reply(message2)
		redirect_to wearables_user_url(@user)
	end

  private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :cellphone)
    end

  def error
    render 'error/error.html.erb'
  end

end
