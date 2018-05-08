class Invitation < ApplicationRecord
  belongs_to :user
  belongs_to :questionnaire
  belongs_to :campaign, optional: true
  has_many :questionnaire_answers, dependent: :destroy
  acts_as_taggable


  # Saving user data into a csv
  def self.to_csv
    attributes = %w{id user_id questionnaire_id completed campaign}
    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.each do |invitation|
        csv << attributes.map{ |attr| invitation.send(attr) || 'null' }.uniq
      end
    end
  end


  # # Saving user data into a csv
  # CSV_HEADER = %w[first_name]
  #
  # def to_csv
  #   CSV.generate do |csv|
  #     csv << CSV_HEADER
  #     all.each do |invitation|
  #       csv << [
  #           invitation.user.first_name,
  #       # "#{user.invitation_ids.join(';')}",
  #
  #
  #       # user.hobbies.pluck(:title).join(', ')
  #       ].uniq
  #       # csv << CSV_HEADER
  #       # user.invitations.each do |invitation|
  #       #   csv << [
  #       #       "this one #{invitation.questionnaire_id}",
  #       #       "this one #{invitation.campaign}",
  #       #       "this one #{invitation.completed}"
  #       #   ].uniq
  #       # end
  #     end
  #   end
  # end

#   # Saving user data into a csv
#   CSV_HEADER = %w[id first_name last_name email cellphone state fitbit_status age py_cluster patient_objective
# gender height weight blood_type tag_list invitation]
#   def self.to_csv
#     CSV.generate do |csv|
#       csv << CSV_HEADER
#       all.each do |user|
#         csv << [
#             user.id,
#             user.first_name,
#             user.last_name,
#             user.email,
#             user.cellphone,
#             user.state,
#             user.fitbit_status,
#             user.age,
#             user.py_cluster,
#             user.patient_objective,
#             user.gender,
#             user.height,
#             user.weight,
#             user.blood_type,
#             user.tag_list,
#
#         # user.hobbies.pluck(:title).join(', ')
#         ].uniq
#       end
#     end
#   end
#
  
  
  
  
end
