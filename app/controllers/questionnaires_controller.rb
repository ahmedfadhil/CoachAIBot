class QuestionnairesController < ApplicationController
  before_action :authenticate_coach_user!
  before_action :check_for_cancel, :only => [:create, :update]
  before_action :set_questionnaire, only: [:show, :edit, :update, :destroy]
  layout 'profile'
  
  # GET /questionnaires
  def index
    @questionnaires = Questionnaire.all

    respond_to do |format|
      format.html
      format.csv {send_data @questionnaires.to_csv}
    end
  end
  
  # GET /questionnaires/1
  def show
    @questionnaire = Questionnaire.find(params[:id])

    respond_to do |format|
      format.html
      format.csv {send_data @questionnaire.to_csv}
    end
  end
  
  # GET /questionnaires/new
  def new
    @questionnaire = Questionnaire.new
  end
  
  # GET /questionnaires/1/edit
  def edit
  end
  
  # POST /questionnaires
  def create
    @questionnaire = Questionnaire.new(questionnaire_params)
    
    if @questionnaire.save
      redirect_to @questionnaire, notice: 'Il questionario è stato creato con successo.'
    else
      render :new
    end
  end
  
  # PATCH/PUT /questionnaires/1
  def update
    if @questionnaire.update(questionnaire_params)
      redirect_to @questionnaire, notice: 'Il questionario è stato aggiornato con successo.'
    else
      render :edit
    end
  end
  
  # DELETE /questionnaires/1
  def destroy
    @questionnaire.destroy
    redirect_to questionnaires_url, notice: 'Il questionario è stato distrutto con successo.'
  end



  def check_for_cancel
    if params[:commit] == "Cancel"
      redirect_to questionnaires_path
    end
  end
  private
  # Use callbacks to share common setup or constraints between actions.
  def set_questionnaire
    @questionnaire = Questionnaire.find(params[:id])
  end
  
  # Only allow a trusted parameter "white list" through.
  def questionnaire_params
    params.require(:questionnaire).permit!
  end
end
