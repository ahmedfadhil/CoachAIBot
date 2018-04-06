class QuestionnaireExport < Xport::Export
  include Xport::CSV
  
  columns do
    # User data
    column :user_id
    column :user_first_name
    column :user_last_name
    column :user_age
    column :user_gender do |row|
      if row.user_gender.nil?
        "Sconosciuto"
      else
        row.user_gender
      end
    end
    column :user_cellphone
    column :user_email
    column :user_cluster do |row|
      row.user_cluster ? row.user_cluster : "Nullo"
    end
    column :user_patient_objective do |row|
      row.user_patient_objective ? row.user_patient_objective : "Sconosciuto"
    end
    column :user_height do |row|
      row.user_height ? row.user_height : "Nullo"
    end
    column :user_weight do |row|
      row.user_weight ? row.user_weight : "Nullo"
    end
    column :user_blood_type do |row|
      row.user_blood_type ? row.user_blood_type : "Nullo"
    end
  
  end
  
  
  # SELECT_OPTIONS = %{
  #     users.id as user_id,
  #     users.first_name as user_first_name,
  #     users.last_name as user_last_name,
  #     users.age as user_age,
  #     users.gender as user_gender,
  #     users.cellphone as user_cellphone,
  #     users.email as user_email,
  #     users.py_cluster as user_cluster,
  #     users.patient_objective as user_patient_objective,
  #     users.height as user_height,
  #     users.weight as user_weight,
  #     users.blood_type as user_blood_type,
  #     plans.id as plan_id,
  #     plans.name as plan_name,
  #     plans.desc as plan_desc,
  #     plans.from_day as plan_from_day,
  #     plans.to_day as plan_to_day,
  #     plans.created_at as plan_created_at,
  #     plans.delivered as plan_delivered,
  #     plans.communicated as plan_communicated,
  #     activities.id as activity_id,
  #     activities.name as activity_name,
  #     activities.desc as activity_desc,
  #     activities.a_type as activity_a_type,
  #     activities.n_times as activity_n_times,
  #     activities.created_at as activity_created_at,
  #     activities.category as activity_category
  #   }.gsub(/\s+/, " ").strip
  #
  #
  def self.all_questionnaire_data
    invitation = Invitation.find(params[:id]).questionnaire.questionnaire_questions
    new invitation
  end
  
  
  # def self.allData
  #   # activites = Activity.joins(:plans, :users).select(select_options)
  #   activites = Activity.joins(:plans, :users).select(SELECT_OPTIONS).order('users.id', 'plans.id', 'activities.id')
  #   new activites
  # end
  #
  # def self.userData(user)
  #   # activites = Activity.joins(:plans, :users).select(select_options)
  #   activites = Activity.joins(:plans, :users).select(SELECT_OPTIONS).where(users: {
  #       id: user.id
  #   }).order('users.id', 'plans.id', 'activities.id')
  #
  #   new activites
  # end


end


#invitation = Invitation.find(params[:id]).questionnaire.questionnaire_questions
# Invitation.last.user
# Invitation.last.questionnaire_answers.last.questionnaire_question
# Invitation.last.questionnaire.questionnaire_questions.last.options
# Invitation.last.user.tag_list
#


# def self.allData
#   # activites = Activity.joins(:plans, :users).select(select_options)
#   activites = Activity.joins(:plans, :users).select(SELECT_OPTIONS).order('users.id','plans.id','activities.id')
#   new activites
# end
#
# def self.userData(user)
#   # activites = Activity.joins(:plans, :users).select(select_options)
#   activites = Activity.joins(:plans, :users).select(SELECT_OPTIONS).where(users: {
#       id: user.id
#   }).order('users.id','plans.id','activities.id')
#   new activites
# end
#




