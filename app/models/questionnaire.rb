class Questionnaire < ApplicationRecord
  has_many :invitations, dependent: :destroy
  has_many :questionnaire_questions, dependent: :destroy

  validates_uniqueness_of :title, message: "Esiste gia' un questionario con questo nome. Scegli un'atro nome!"
  # validates :questionnaire_questions, presence: true
  validates :questionnaire_questions, presence: true
  validates :title, presence: true


  accepts_nested_attributes_for :questionnaire_questions, allow_destroy: true, :reject_if => lambda {|attributes| attributes[:text].blank?}


  #
  # # Saving user data into a csv
  # def self.to_csv
  #   attributes = %w{id title desc completed initial}
  #
  #   CSV.generate(headers: true) do |csv|
  #     csv << attributes
  #     all.each do |invitation|
  #       csv << attributes.map{ |attr| invitation.send(attr) || "null" }.uniq
  #     end
  #   end
  # end
  #


  # Saving user data into a csv
  CSV_HEADER = %w[id title desc completed initial]

  def self.to_csv
    CSV.generate do |csv|
      csv << CSV_HEADER
      all.each do |questionniare|
        csv << [
            questionniare.id,
            questionniare.title,
            questionniare.desc,
            questionniare.completed,
            questionniare.completed,
            questionniare.initial,
            "XXX #{questionniare.questionnaire_question_ids.join(';')}",

        # user.hobbies.pluck(:title).join(', ')
        ].uniq
        csv << CSV_HEADER
        questionniare.questionnaire_questions.each do |qqs|
          +"\n"
          csv << [
              "qqs_id #{qqs.id}",
              "type #{qqs.q_type}",
              "text: #{qqs.text}",
              "Q_id #{qqs.questionnaire_id}",
              "Options #{qqs.option_ids.join(';')}",
              "Options #{qqs.questionnaire_answer_ids.join(';')}"
          ].uniq
        end
        csv << CSV_HEADER
        questionniare.questionnaire_questions.each do |qqs|
          qqs.options.each do |op|
            +"\n"
            csv << [
                "op_id #{op.id}",
                "Op_text #{op.text}",
                "questionnaire_question_id: #{op.questionnaire_question_id}",
                "score: #{op.score}"
            # "Options #{op.option_ids.join(';')}",
            ].uniq
          end
          csv << CSV_HEADER
          questionniare.questionnaire_questions.each do |qqs|
            qqs.questionnaire_answers.each do |ans|
              +"\n"
              csv << [
                  "Ans_id: #{ans.id}",
                  "Ans_text: #{ans.text}",
                  "Invit_id: #{ans.invitation_id}",
                  "QQ_id: #{ans.questionnaire_question_id}"
              # "Options #{op.option_ids.join(';')}",
              ].uniq
            end
        end
      end
    end
    end
  end
end
