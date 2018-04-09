class ObjectivesController < ApplicationController
	before_action :authenticate_coach_user!, only: [:index, :show, :invite]
	respond_to :html
	layout 'profile'

	def index
	end

	def show
		@user = User.find(params[:id])
	end

	def new
		@user = User.find(params[:id])
		@objective = Objective.new(user: @user)
	end

	def create
		@user = User.find(params[:id])
		@objective = @user.objectives.build(objective_params)
		@objective.fitbit_integration = :fitbit_enabled if @user.fitbit_enabled?
		if @objective.save
			Thread.new {
				message1 = "Cordiale utente, il tuo coach ha pianificato un nuovo programma di allenamento. Visita la sezione ALLENAMENTO per ulteriori informazioni."
				ga = GeneralActions.new(@user, nil)
				ga.send_reply(message1)
			}
			redirect_to(user_objectives_url(@user), notice: "Obiettivo creato con successo!")
		else
			render action: "new"
		end
	end

	def details
		@objective = Objective.find(params[:id])
	end

	def objective_params
		params.require(:objective).permit(:start_date, :end_date, :activity, :steps, :distance)
	end

end
