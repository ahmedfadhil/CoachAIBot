class Objective < ApplicationRecord
	belongs_to :user
	has_many :weekly_logs
	enum activity: { steps: 0, distance: 1 }

	validates :start_date, :end_date, presence: { message: 'Deve essere presente' }
	validate :start_and_end_date_must_be_consistent
	def start_and_end_date_must_be_consistent
		if !start_date.nil? && start_date < Date.today
			errors.add(:start_date, "Non può avere inizio nel passato")
		end

		return if start_date.nil? || end_date.nil?

		if start_date >= end_date
			errors.add(:start_date, "Deve iniziare prima della data di fine")
			errors.add(:end_date, "Deve finire dopo la data di inizio")
			return
		end

		days = TimeDifference.between(start_date, end_date).in_days
		if days < 10
			errors.add(:start_date, "la attività deve durare almeno 10 giorni")
			errors.add(:end_date, "La attività deve durare almeno 10 giorni")
		end

		user.objectives.each do |objective|
			next unless objective.persisted?

			formatted_start_date = objective.start_date.strftime("%-d %B %Y")
			formatted_end_date = objective.end_date.strftime("%-d %B %Y")
			if start_date >= objective.start_date && start_date <= objective.end_date
				errors.add(:start_date, "Non può iniziare tra i giorni #{formatted_start_date} e #{formatted_end_date}")
			end
			if end_date >= objective.start_date && end_date <= objective.end_date
				errors.add(:end_date, "Non può terminare tra i giorni #{formatted_start_date} e #{formatted_end_date}")
			end
		end
	end

	validate :activity_must_have_attribute
	def activity_must_have_attribute
		if steps? && (steps.nil? || steps <= 0)
			errors.add(:steps, "Deve essere un numero intero positivo")
		elsif distance? && (distance.nil? || distance <= 0)
			errors.add(:distance, "Deve essere un numero intero positivo")
		end
	end
end
