class PlansController < ApplicationController

  def new
    @plan = Plan.new plan_id
  end

  private

    def plan_params
      params.require(:plan).permit(:name, :desc)
    end

    def plan_id
      params.require(:plan).permit(:id)
    end
end
