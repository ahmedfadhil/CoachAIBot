require "#{Rails.root}/lib/modules/communicator"
require "#{Rails.root}/lib/bot/image_solver"
require 'csv'

class FeaturesManager
  def init
  end

  def communicate_profiling_done!(user)
    communicator = Communicator.new
    communicator.communicate_profiling_finished user
  end

  def save_features_to_csv(user)
    path = Rails.root.join('csvs', 'features.csv')
    CSV.open(path, 'a+') do |csv|
      features = generate_features(user)
      csv << [user.id, user.age, features['health_personality'], decode_work_physical_activity(features['work_physical']),
              decode_foot_bicycle(features['foot_bicycle']), decode_stress(features['stress'])]
    end
  end

  # not used because an asset needs to be recompiled
  def save_telegram_profile_img(user)
    begin
      solver = ImageSolver.new
      uri = solver.solve(user.telegram_id)
      stream = open(uri)
      file_name = stream.base_uri.to_s.split('/')[-1]
      user.profile_img = "public/assets/user_profile_img/#{user.id}_#{file_name}"
      path = Rails.root.join('public/assets/user_profile_img', "#{user.id}_#{file_name}")
      IO.copy_stream(stream, path)
    rescue Exception
      user.profile_img = default_profile_img
    end
    user.save
  end


  def generate_features(user) #from questionnaires
    features = {}
    Invitation.where(user: user).each do |invitation|
      work_physical_question = invitation.questionnaire.questionnaire_questions.where(text: 'Il tuo lavoro richiede stare seduti o essere in movimento?')
      foot_bicycle_question = invitation.questionnaire.questionnaire_questions.where(text: 'Quanto spesso vai in bici o a piedi?')
      health_personality_question = invitation.questionnaire.questionnaire_questions.where(text: 'Se dovessi dare un voto da 1(insufficiente) a 5(ottimo) come valuteresti complessivamente la tua salute?')
      stress_question = invitation.questionnaire.questionnaire_questions.where(text: 'Come valuteresti la quantita\' di stress nella tua vita?')
      unless work_physical_question.empty?
        features['work_physical'] = invitation.questionnaire_answers.where(questionnaire_question_id: work_physical_question.first.id).first.text
      end
      unless foot_bicycle_question.empty?
        features['foot_bicycle'] = invitation.questionnaire_answers.where(questionnaire_question_id: foot_bicycle_question.first.id).first.text
      end
      unless health_personality_question.empty?
        features['health_personality'] = invitation.questionnaire_answers.where(questionnaire_question_id: health_personality_question.first.id).first.text
      end
      unless stress_question.empty?
        features['stress'] = invitation.questionnaire_answers.where(questionnaire_question_id: stress_question.first.id).first.text
      end
    end
    features
  end



  def default_profile_img
    'rsz_user_icon.png'
  end

  def decode_work_physical_activity(code)
    case code
      when 'stare seduti'
        'Mostly sitting (Involves movement less than 30 minutes per week)'
      when 'entrambe'
        'Moderate (involves both sitting and moving)'
      else
        'Mostly moving (Involves movement more than 3days per week)'
    end
  end

  def decode_foot_bicycle(code)
    case code
      when 'Raramente'
        '1-2 times a week'
      when 'A volte'
        '> 3 times a week'
      else
        'Most of the time'
    end
  end

  def decode_stress(code)
    case code
      when 'per niente stressato'
        'Low'
      when 'poco stressato'
        'Medium'
      else
        'High'
    end
  end

  # not used by the system!!!!!!!!!!!!
  def create_data_set
    users = User.all
    users.each do |user|
      path = Rails.root.join('csvs', 'status_classification_dataset.csv')
      unless user.py_cluster.nil?
        CSV.open(path, 'a+') do |csv|
          features = generate_features(user)
          csv << [user.id, user.age, features['health_personality'], decode_work_physical_activity(features['work_physical']),
                  decode_foot_bicycle(features['foot_bicycle']), decode_stress(features['stress']), user.py_cluster]
        end
      end
    end
  end

end