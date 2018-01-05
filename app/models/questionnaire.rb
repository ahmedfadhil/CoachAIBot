class Questionnaire < ApplicationRecord
  has_many :users, :through => :invitations
  has_many :questionnaire_questions

  def f
    title = %Q(Indagine sull'attivita' fisica)
    question_hash = {
        %Q(Qual'e' la tua attivita' preferita di sport tra quelle indicate?) => ["ciclismo","nuoto","corsa", "yoga", "danza", "sport di squadra", "camminata", "altro", "non ho uno sport preferito"],
        %Q(Quanto spesso ti eserciti?) => ["Quasi mai","3 o piu' volte in settimana","1/2 volte in settimana"],
        %Q(Con che intensita' ti eserciti?) => ["tranquilla","media", "ci vado vesante", "non mi esercito"],
        %Q(Il tuo lavoro richiede stare seduti o essere in movimento?) => ["muoversi", "stare seduti", "entrambe"],
        %Q(Quanto spesso vai in bici o a piedi?) => ["A volte","Raramente","Spesso"]
    }

    questionnaire = Questionnaire.create(title: title)

    question_hash.each { |key, value|
      question = questionnaire.questionnaire_questions.create(text: key)
      value.each { |e|
        question.options.create(text: e)
      }
    }
  end
end
