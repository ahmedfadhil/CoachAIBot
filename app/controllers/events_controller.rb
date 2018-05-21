class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_coach_user!

  def index
    @events = Event.where(start: params[:start]..params[:end])
  end

  def show
  end

  def new
    @event = Event.new
  end

  def edit
  end

  def create
    @event = Event.new(event_params)
		@event.coach_user = current_coach_user
    @event.save!
  end

  def update
    @event.update(event_params)
  end

  def destroy
    @event.destroy
  end

	def reminders
		@events = Event.where("start >= ?", Time.current - 10.minutes).where(coach_user: current_coach_user).where.not(reminder_type: 'disabled')
	end

  private
  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :date_range, :start, :end, :color, :reminder_type, :reminder_range)
  end
end