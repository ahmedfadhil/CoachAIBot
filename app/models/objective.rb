class Objective < ApplicationRecord
	belongs_to :user
	enum scheduler: { weekly: 0, monthly: 1 }
	enum activity: { steps: 0, distance: 1 }

	validates :start_date, :end_date, presence: { message: 'Deve essere presente' }
	validate :start_and_end_date_must_be_consistent
	def start_and_end_date_must_be_consistent
		return if start_date.nil? || end_date.nil?
		if start_date < Date.today
			errors.add(:start_date, "Non può avere inizio nel passato")
		end
		if start_date >= end_date
			errors.add(:start_date, "Deve iniziare prima della data di fine")
			errors.add(:end_date, "Deve iniziare dopo la data di inizio")
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
