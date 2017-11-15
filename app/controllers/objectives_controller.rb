class ObjectivesController < ApplicationController
	before_action :authenticate_coach_user!, only: [:index, :show, :invite]
	respond_to :html
	layout 'cell_application'

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
		if @objective.save
			redirect_to(user_objectives_url(@user), notice: "Obiettivo creato con successo!")
		else
			render action: "new"
		end
	end

	def objective_params
		params.require(:objective).permit(:scheduler, :start_date, :end_date, :activity, :steps, :distance)
	end

end
