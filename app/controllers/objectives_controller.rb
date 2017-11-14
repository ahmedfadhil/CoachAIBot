class ObjectivesController < ApplicationController
	before_action :authenticate_coach_user!, only: [:index, :show, :invite]
	respond_to :html
	layout 'cell_application'

	def index
	end

	def show
		@user = User.find(params[:id])
	end
end
